import _isEmpty from "ramda/es/isEmpty"; import _test from "ramda/es/test"; import _type from "ramda/es/type"; #auto_require: _esramda
import {func} from "ramda-extras" #auto_require: esramda-extras

import {customAlphabet} from 'nanoid'
nanoid = customAlphabet '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 5

import {ValidationError, FaultError, WeirdError, IntegrationError, AuthError, PermissionError, DBError,
stringifyError} from '../shared/errors'
import createDB from './db'
import createPDB from './pdb'


# Glue code for needed to setup a small backend with our architecture.
#
# res is assumed to have a ctx object containing
# rid, uid, cid 	= request, user, customer id
# log 						= a log function that adds rid, uid, cid when loggnig to console


# Always write rid, uid and cid from ctx so we can easily search and filter logs
export logger = (ctx, args...) ->
	console.log "!rid:#{ctx.rid}!uid:#{ctx.uid || ''}!cid:#{ctx.cid || ''}!", args...

logger.error = (ctx, args...) ->
	console.error "!rid:#{ctx.rid}!uid:#{ctx.uid || ''}!cid:#{ctx.cid || ''}!", args...


# Lets you specify an endpoint in a succinct and unifrom way. Assumes you've set res.ctx 
export createEndpoint = (config, model) ->
	db = createDB {pool: config.pool, log: config.log || logger}

	pdb = createPDB
		db: db
		model: model
		log: config.log || logger
		safeGuards: config.safeGuards

	return (spec, f, meta = {}) ->
		return (req, res) ->
			console.log 'res'
			console.log 'res.status', res.status
			console.log 'res.end', res.end
			console.log '--------------------------------------------------------------------------------' 
			# console.log 'req', req
			# if req.method != 'POST' then throw new Error 'Not correct'


			# baseCtx = {rid: nanoid(), uid: undefined, cid: undefined}
			baseCtx = {rid: nanoid(), uid: "1", cid: "aaa"}
			log = (args...) -> logger baseCtx, args...
			log.error = (args...) -> logger.error baseCtx, args...



			sqlUnsafe = (sql, params = [], fullResult = false) -> db.run {log}, sql, params, fullResult

			res.ctx = {...baseCtx, log, sqlUnsafe}
			res.ctx.readCtxUnsafe = (query) -> pdb.readCtxUnsafe res.ctx, query

			if _isEmpty spec then f2 = (a) -> f a, res.ctx, req, res
			else f2 = func spec, (a) -> f a, res.ctx, req, res

			try
				if !_test(/devData/, req.url) then log req.url
				await config.extendCtx req, res, meta
				pdbApi = pdb.makeApi res.ctx
				Object.assign res.ctx, pdbApi
				result = await f2 req.body
				if result == undefined then # do nothing, f wants to handle response itself
				else if result == null then res.send 'null' # support sending nulls
				else if result.constructor.name == 'ServerResponse'
					# f is obsiously using res (ServerResponse) so assume it handles res.send ifself, i.e. do nothing here
				else res.json result
			catch err
				handleError res, err


# We want to be able to exit any api flow by throwing but we want to handle them gracefully,
# eg. a Validation or Permission error should not result in a 500 which is reserved for unhandled errors.
handleError = (res, err) ->
	console.log 'handleError', err, 'err instanceof AuthError', err instanceof AuthError, 'type:', _type(err)
	if err instanceof AuthError
		res.ctx.log.error err
		# console.log 'wwwwwwwwwwwwwwww res', res
		res.status(401).json(stringifyError(err))
	else if err instanceof ValidationError ||
					err instanceof FaultError ||
					err instanceof WeirdError ||
					err instanceof IntegrationError ||
					err instanceof PermissionError ||
					err instanceof DBError
		res.ctx.log.error err
		res.status(444).json(stringifyError(err))
	else
		res.ctx.log.error err
		res.status(500).json(stringifyError(err))
		# throw err # throw any other kind so that nextjs error view in the browser works as expected


# We might want to create a context in other places than for endpoints, eg. in getServerSideProps.
# Returns a ctx by creating and calling a fake endpoint.
# This is a test, not sure if it has too much negative impact on performance.
export createContext = (config, model, req, res) ->
	console.log 7 
	fakeEndpointF = createEndpoint config, model
	fakeApiF = (a, ctx, req, res) -> return ctx
	fakeApiEndpoint = fakeEndpointF {}, fakeApiF, {isPublic: false}
	res.json = (x) -> x
	console.log 8 
	ctx = await fakeApiEndpoint req, res
	console.log 9 
	return ctx




















