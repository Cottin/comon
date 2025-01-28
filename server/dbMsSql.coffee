import _equals from "ramda/es/equals"; import _type from "ramda/es/type"; import _uniq from "ramda/es/uniq"; import _without from "ramda/es/without"; #auto_require: _esramda
import {sf0} from "ramda-extras" #auto_require: esramda-extras

# NOTE: After 1 day of trouble shooting - we can't import mssql here when running on node v12 since then a
#				es6 syntax error occurs about PORT and ??. Very weird but simple solution is to pass mssql in config.
# import mssql from 'mssql'

import {shortResult, ensurePrepareResult} from './dbHelpers'

if !performance then performance = {now: () -> Date.now()}

# Gives you a DB api for mssql
# eg. {sql, transaction} = createDB ...
# 		run sql"select * from customer where id = #{1}'
# 		transaction (tr) ->
#				tr.run sql"insert into customer ..."
#				tr.run sql.dryRun"update customer ..."
#			or if you want to build query:
# 		run sql"select * from customer where id = #{1}".add" and active = #{true}"
#
# Note that all db[Provider].coffee should expose the same api so they are interchangable
export createDB = (config) ->
	pool = await config.getPool()
	if _type(config.log) != 'Function' then throw new Error 'missing log function in config'

	run = (prepareResult) -> queryFn pool, config, prepareResult
	run.dry = (prepareResult) -> queryFn pool, config, prepareResult, true

	# Temporarily removed - Remove completely december 2024
	# sql = (strings, ...values) ->
	# 	prepareResult = prepareWithParams strings, values...
	# 	return queryFn pool, config, prepareResult
	# sql.dryRun = (strings, ...values) ->
	# 	prepareResult = prepareWithParams strings, values...
	# 	return queryFn pool, config, prepareResult, true

	# sql.build = (strings, ...values) ->
	# 	recursive = prepareWithParamsRecursive strings, values...
	# 	recursive.run = () ->
	# 		queryFn pool, config, this.slice(0, 3)
	# 	recursive.dryRun = () ->
	# 		queryFn pool, config, this.slice(0, 3), true
	# 	return recursive


	transaction = (fn) ->
		trans = new config.mssql.Transaction pool

		# Temporarily removed - Remove completely december 2024
		# sqlTrans = (strings, ...values) ->
		# 	prepareResult = prepareWithParams strings, values...
		# 	return queryFn trans, config, prepareResult
		# sqlTrans.dryRun = (strings, ...values) ->
		# 	prepareResult = prepareWithParams strings, values...
		# 	return queryFn trans, config, prepareResult, true

		runTrans = (prepareResult) -> queryFn trans, config, prepareResult
		runTrans.dry = (prepareResult) -> queryFn trans, config, prepareResult, true

		try
			await trans.begin()
			config.log 'BEGIN'
			result = await fn {run: runTrans}
			await trans.commit()
			config.log 'COMMIT'
			return result
		catch err
			await trans.rollback()
			config.log 'ROLLBACK'
			throw err

	query = () -> throw new Error 'query not supported in mssql, use sql function'
	releaseIfNeeded = () -> console.log 'release not needed with mssql'

	return {query, run, transaction, releaseIfNeeded}

queryFn = (poolOrTransaction, config, prepareResult, dryRun = false) ->
	t0 = performance.now()
	ensurePrepareResult prepareResult
	try
		request = new config.mssql.Request poolOrTransaction
		[sqlQuery, params, stringsToUse] = prepareResult
		if dryRun
			ret = undefined
			resString = 'DRY RUN = QUERY NOT EXECUTED'
		else
			res = await request.query stringsToUse, ...params
			ret = res.recordset
			# Note that each statement results in a 1 in rowsAffected.
			# Seems tools like VS Code etc. parses the query and compares if with the result to realize what
			# item of rowsAffected is the most important one. This is too advanced to do here, so instead just
			# do a simple clean up like below
			if res.rowsAffected.length == 0 then rowsAffectedClean = []
			else if _equals [1], _uniq(res.rowsAffected) then rowsAffectedClean = [1]
			else
				uniquesWithout1 = _without([1], _uniq(res.rowsAffected))
				if uniquesWithout1.length == 1 then rowsAffectedClean = uniquesWithout1
				else rowsAffectedClean = res.rowsAffected

			resString = if !ret then "rows affected: #{sf0 rowsAffectedClean}" else shortResult ret

		config.log '\n' + sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - #{resString}"
		return ret
	catch err
		config.log '\n', sqlQuery, params, "- #{Math.round(performance.now() - t0)} ms - ERROR"
		console.error 'err', err
		throw err
