 #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras
import util from 'util'

import {db} from '@vercel/postgres'

import {prepareDangerous, shortResult, prepareWithParams} from './dbHelpers'

# Gives you a postgres api for vercel/postgres
# eg. {sql, query, transaction} = createDB ...
# 		sql"select * from customer where id = #{1}'
# 		query 'select * from customer where id = $1', [1]
# 		transaction (tr) ->
#				tr.sql"insert into customer ..."
#				tr.sql"update customer ..."
# Note that all db[Provider].coffee should expose the same api so they are interchangable
export createDB = (config) ->
	client = null

	sql = (strings, ...values) ->
		[sqlQuery, params] = prepareWithParams strings, ...values
		return query sqlQuery, params

	query = (sqlQuery, params) ->
		if !client then console.log 'db.connect!!!!!!!!'; client = await db.connect()
		t0 = performance.now()
		try
			res = await client.query sqlQuery, params
			ret = if res?.rows then res.rows else res
			config.log sqlQuery, params, " - #{Math.round(performance.now() - t0)} ms - #{shortResult ret}"
			return ret
		catch err
			config.log sqlQuery, params, " - #{Math.round(performance.now() - t0)} ms - ERROR"
			throw err

	transaction = (fn) ->
		try
			await sql"BEGIN"
			result = await fn {sql, query}
			await sql"COMMIT"
			return result
		catch err
			await sql"ROLLBACK"
			throw err


	return {sql, query, transaction}


