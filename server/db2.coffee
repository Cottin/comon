import _replace from "ramda/es/replace"; import _toLower from "ramda/es/toLower"; import _toUpper from "ramda/es/toUpper"; #auto_require: _esramda
import {$} from "ramda-extras" #auto_require: esramda-extras

# Gives you a postgres connection to run sql queries against (optionally using transactions)
# eg. db = createDB ...
# 		db.run 'SELECT * FROM CUSTOMER'
# 
##############################################################################################################

# Tips to use in your backend if it makes sense for you:

# COUNT is returned as String not Number by driver in order to be correct.
# The following is a workaround that will work for 32-bit big ints but not for 64-bit.
# This project will most probably nevery use a COUNT that returns a 64-bit result, but
# watch out for other big int use-cases than COUNT maybe. Discussion below:
# https://github.com/brianc/node-postgres/issues/378
# https://github.com/tgriesser/knex/issues/387
# https://stackoverflow.com/questions/39168501/pg-promise-returns-integers-as-strings
# https://github.com/vitaly-t/pg-promise/issues/128
# SELECT typname,oid FROM pg_type;
# pg.types.setTypeParser(20, parseInt)

# By default date types parses as dates 2019-07-01T07:00:00.000Z, but it's easier for us to handle
# strings 2019-07-01. Note that this only effect type date not timestamp etc.
# parseDate = (dateStr) -> dateStr.substr(0,10)
# pg.types.setTypeParser(1082, parseDate)


export createDB = (config) ->
	pool = config.pool


	run = (sql, params = null, fullResult = false) ->
		config.log sql
		if params then config.log params
		try
			res = await pool.query sql, params
		catch err
			console.error '#################### DB-Error pool.query'
			throw err

		if fullResult then return res
		else return res.rows

	transaction = () ->
		try
			client = await pool.connect()
		catch err
			console.error '#################### DB-Error pool.connect'
			throw err

		# https://github.com/brianc/node-postgres/issues/433
		clientQuery = (sql, params = null, fullResult = false) ->
			config.log sql
			if params then config.log params
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




# Standard is to have snake case in sql database, but we want camelCase in results.
# We could map over all items in the results and change change them but it seems unecessarily expensive.
# We could modify all queries to add "my_field AS myField" but that makes the queries long and ugly.
# This is a hack that modifies pg which achieves what we want and is probably faster (not checked though).
# See https://github.com/hoegaarden/pg-camelcase for the original idea
export injectSnakeToCamel = (pg) ->
  queryProto = pg.Query.prototype
  handleRowDesc = queryProto.handleRowDescription

  queryProto.handleRowDescription = (msg) ->
    msg.fields.forEach (field) ->
      field.name = snakeToCamel field.name
    handleRowDesc.call this, msg


camelToSnake = (s) -> $ s, _replace(/[A-Z]/g, (s) -> '_' + _toLower s)
snakeToCamel = (s) -> $ s, _replace(/_[a-z]/g, (s) -> _toUpper s[1])
