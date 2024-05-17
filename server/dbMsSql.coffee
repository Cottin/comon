import _type from "ramda/es/type"; #auto_require: _esramda
import {sf0} from "ramda-extras" #auto_require: esramda-extras

# NOTE: After 1 day of trouble shooting - we can't import mssql here when running on node v12 since then a
#				es6 syntax error occurs about PORT and ??. Very weird but simple solution is to pass mssql in config.
# import mssql from 'mssql'

import {shortResult, prepareWithParams} from './dbHelpers'

if !performance then performance = {now: () -> Date.now()}

# Gives you a DB api for mssql
# eg. {sql, transaction} = createDB ...
# 		sql"select * from customer where id = #{1}'
# 		transaction (tr) ->
#				tr.sql"insert into customer ..."
#				tr.sql.dryRun"update customer ..."
# Note that all db[Provider].coffee should expose the same api so they are interchangable
export createDB = (config) ->
	pool = await config.getPool()
	if _type(config.log) != 'Function' then throw new Error 'missing log function in config'

	sql = (strings, ...values) -> queryFn(pool, config) strings, ...values
	sql.dryRun = (strings, ...values) -> queryFn(pool, config, true) strings, ...values


	transaction = (fn) ->
		trans = new config.mssql.Transaction pool

		sqlTrans = (strings, ...values) -> queryFn(trans, config) strings, ...values
		sqlTrans.dryRun = (strings, ...values) -> queryFn(trans, config, true) strings, ...values

		try
			await trans.begin()
			config.log 'BEGIN'
			result = await fn {sql: sqlTrans}
			await trans.commit()
			config.log 'COMMIT'
			return result
		catch err
			await trans.rollback()
			config.log 'ROLLBACK'
			throw err

	query = () -> throw new Error 'query not supported in mssql, use sql function'
	releaseIfNeeded = () -> console.log 'release not needed with mssql'

	return {sql, query, transaction, releaseIfNeeded}


queryFn = (poolOrTransaction, config, dryRun = false) -> (strings, ...values) ->
	t0 = performance.now()
	try
		request = new config.mssql.Request poolOrTransaction
		[sqlQuery, params, stringsToUse] = prepareWithParams strings, ...values
		if dryRun
			ret = undefined
			resString = 'DRY RUN = QUERY NOT EXECUTED'
		else
			res = await request.query stringsToUse, ...params
			ret = res.recordset
			resString = if !ret then "rows affected: #{sf0 res.rowsAffected}" else shortResult ret

		config.log '\n' + sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - #{resString}"
		return ret
	catch err
		config.log '\n', sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - ERROR"
		throw err
