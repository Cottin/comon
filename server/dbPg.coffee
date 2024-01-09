 #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras

import {prepareDangerous, shortResult, prepareWithParams} from './dbHelpers'



# Gives you a postgres api for node-postgres
# eg. {sql, query, transaction} = createDB ...
# 		sql"select * from customer where id = #{1}'
# 		query 'select * from customer where id = $1', [1]
# 		transaction (tr) ->
#				tr.sql"insert into customer ..."
#				tr.sql"update customer ..."
# Note that all db[Provider].coffee should expose the same api so they are interchangable
export createDB = (config) ->
	pool = config.pool

	query = queryFn pool, config

	sql = (strings, ...values) ->
		[sqlQuery, params] = prepareWithParams strings, ...values
		return query sqlQuery, params


	transaction = (fn) ->
		# https://github.com/brianc/node-postgres/issues/433
		client = await pool.connect()
		queryTr = queryFn client, config

		sqlTr = (strings, ...values) ->
			[sqlQuery, params] = prepareWithParams strings, ...values
			return queryTr sqlQuery, params

		try
			await sqlTr'BEGIN'
			result = await fn {sql: sqlTr, query: queryTr}
			await sqlTr'COMMIT'
			return result
		catch err
			await sqlTr'ROLLBACK'
			throw err
		finally
			client.release()

	return {sql, query, transaction}


queryFn = (poolOrClient, config) -> (sqlQuery, params) ->
	t0 = performance.now()
	try
		res = await poolOrClient.query sqlQuery, params
		ret = if res?.rows then res.rows else res
		config.log sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - #{shortResult ret}"
		return ret
	catch err
		config.log sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - ERROR"
		throw err
