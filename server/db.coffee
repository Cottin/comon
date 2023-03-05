 #auto_require: esramda
import {} from "ramda-extras" #auto_require: esramda-extras

import pg from 'pg'


# Gives you a postgres connection to run sql queries against (optionally using transactions)
# eg. db = createDB ...
# 		db.run ctx, 'SELECT * FROM CUSTOMER'
# 
# Note: Lets you supply a ctx object if you need a more stateful execution
##############################################################################################################


# COUNT is returned as String not Number by driver in order to be correct.
# The following is a workaround that will work for 32-bit big ints but not for 64-bit.
# This project will most probably nevery use a COUNT that returns a 64-bit result, but
# watch out for other big int use-cases than COUNT maybe. Discussion below:
# https://github.com/brianc/node-postgres/issues/378
# https://github.com/tgriesser/knex/issues/387
# https://stackoverflow.com/questions/39168501/pg-promise-returns-integers-as-strings
# https://github.com/vitaly-t/pg-promise/issues/128
# SELECT typname,oid FROM pg_type;
pg.types.setTypeParser(20, parseInt)

# By default date types parses as dates 2019-07-01T07:00:00.000Z, but it's easier for us to handle
# strings 2019-07-01. Note that this only effect type date not timestamp etc.
parseDate = (dateStr) -> dateStr.substr(0,10)
pg.types.setTypeParser(1082, parseDate)


export default createDB = (config) ->
	pool = config.pool


	run = (ctx, sql, params = null, fullResult = false) ->
		ctx.log sql
		if params then ctx.log params
		try
			res = await pool.query sql, params
		catch err
			console.error '#################### DB-Error pool.query'
			throw err

		if fullResult then return res
		else return res.rows

	transaction = (ctx) ->
		try
			client = await pool.connect()
		catch err
			console.error '#################### DB-Error pool.connect'
			throw err

		# https://github.com/brianc/node-postgres/issues/433
		clientQuery = (sql, params = null, fullResult = false) ->
			ctx.log sql
			if params then ctx.log params
			res = await client.query sql, params
			if fullResult then return res
			else return res.rows

		begin = -> await clientQuery 'BEGIN', null, true
		commit = -> await clientQuery 'COMMIT', null, true
		rollback = -> await clientQuery 'ROLLBACK', null, true
		release = -> client.release()
		runF = (sql, params = null) ->
			res = await clientQuery sql, params
			return res

		# Assumes you do an insert with RETURNING id and returns the newId to you
		runF.insert = (sql, params) ->
			res = await runF sql, params
			{id: newId} = res[0]
			return newId

		return {begin, commit, rollback, release, run: runF}


	return {run, transaction}



