import _includes from "ramda/es/includes"; #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras

import {shortResult, prepareWithParams, prepareWithParamsRecursive, ensurePrepareResult, sql} from './dbHelpers'



# Gives you a DB api for node-postgres
# eg. {sql, query, transaction} = createDB ...
# 		run sql"select * from customer where id = #{1}'
# 		query 'select * from customer where id = $1', [1]
# 		transaction (tr) ->
#				tr.run sql"insert into customer ..."
#				tr.run sql"update customer ..."
# Note that all db[Provider].coffee should expose the same api so they are interchangable
export createDB = (config) ->
	pool = config.pool

	query = queryFn pool, config

	run = (prepareResult) -> query prepareResult
	run.dry = (prepareResult) -> query prepareResult, true

	# Temporarily removed - removed fully dec 2024
	# sql = (strings, ...values) ->
	# 	prepareResult = prepareWithParams strings, ...values
	# 	return query prepareResult
	# sql.dryRun = (strings, ...values) ->
	# 	prepareResult = prepareWithParams strings, ...values
	# 	return query prepareResult, true

	# sql.build = (strings, ...values) ->
	# 	recursive = prepareWithParamsRecursive strings, values...
	# 	recursive.run = () ->
	# 		return query this.slice(0, 3)
	# 	recursive.dryRun = () ->
	# 		return query this.slice(0, 3), true
	# 	return recursive


	transaction = (fn) ->
		# https://github.com/brianc/node-postgres/issues/433
		client = await pool.connect()
		queryTrans = queryFn client, config

		# Temporarily removed - removed fully dec 2024
		# sqlTrans = (strings, ...values) ->
		# 	prepareResult = prepareWithParams strings, ...values
		# 	return queryTrans prepareResult

		runTrans = (prepareResult) -> queryTrans prepareResult
		runTrans.dry = (prepareResult) -> queryTrans prepareResult, true

		try
			await sqlTrans sql'BEGIN'
			result = await fn {run: runTrans, query: queryTrans}
			await sqlTrans sql'COMMIT'
			return result
		catch err
			await sqlTrans sql'ROLLBACK'
			throw err
		finally
			client.release()

	releaseIfNeeded = () -> console.log 'release not needed with pg'

	return {run, query, transaction, releaseIfNeeded}


queryFn = (poolOrClient, config) -> (prepareResult, dryRun = false) ->
	t0 = performance.now()
	[sqlQuery, params] = ensurePrepareResult prepareResult
	try
		if dryRun
			ret = undefined
			resString = 'DRY RUN = QUERY NOT EXECUTED'
		else
			res = await poolOrClient.query sqlQuery, params
			if res.command == 'SELECT'
				ret = res.rows
				resString = shortResult ret
			else if _includes(res.command, ['INSERT', 'UPDATE', 'DELETE'])
				ret = {}
				resString = "rows affected: #{res.rowCount}"
			else
				throw new Error 'Not yet implemented'

		config.log '\n' + sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - #{resString}"
		return ret
	catch err
		config.log '\n' + sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - ERROR"
		throw err
