{match} = R = require 'ramda' #auto_require: ramda
{isNilOrEmpty} = RE = require 'ramda-extras' #auto_require: ramda-extras
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

{Pool} = pg = require 'pg'

# {log} = require './logger'
log = () -> console.log 'TODO'


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


pool = new Pool
	host: process.env.DB_HOST
	port: process.env.DB_PORT
	database: process.env.DB_DATABASE
	user: process.env.DB_USER
	password: process.env.DB_PASS
	max: 20
	idleTimeoutMillis: 30000
	connectionTimeoutMillis: 2000

pool.on 'error', (err, client) ->
	console.error('Postgres: Unexpected error on idle client', err)
	process.exit(-1)


module.exports =
	run: (ctx, sql, params = null, fullResult = false) ->
		ctx.log sql
		if params then ctx.log params
		res = await pool.query sql, params
		if fullResult then return res
		else return res.rows

	transaction: (ctx) ->
		# if !ctx || !ctx.cid || isNaN(ctx.cid) then throw new ServerError 'ctx invalid cid'
		if isNilOrEmpty ctx then throw new Error 'ctx missing'
		# if isNilOrEmpty model then throw new ServerError 'model missing'
		client = await pool.connect()
		# https://github.com/brianc/node-postgres/issues/433
		clientQuery = (sql, params = null) ->
			ctx.log sql
			if params then ctx.log params
			return client.query sql, params

		ret = 
			begin: -> await clientQuery 'BEGIN'
			commit: -> await clientQuery 'COMMIT'
			rollback: -> await clientQuery 'ROLLBACK'
			release: -> client.release()
			runSql: (sql, params = null) ->
				res = await clientQuery sql, params
				return res

		# Assumes you do an insert with RETURNING id and returns the newId to you
		ret.runSql.insert = (sql, params) ->
			res = await ret.runSql sql, params
			{id: newId} = res.rows[0]
			return newId

		return ret



