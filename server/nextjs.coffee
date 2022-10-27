import both from "ramda/es/both"; import has from "ramda/es/has"; import isEmpty from "ramda/es/isEmpty"; import isNil from "ramda/es/isNil"; #auto_require: esramda
import {change, mapO, func, $} from "ramda-extras" #auto_require: esramda-extras

import {customAlphabet} from 'nanoid'
nanoid = customAlphabet '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 5

import {ValidationError, FaultError, WeirdError, IntegrationError, AuthError, PermissionError, DBError,
stringifyError} from '../shared/errors'
import {validateCtx, validateDelta, validateEntityId} from './serverUtils'
import createDB from './db'
import createPDB from './pdb'
import popsiql from 'popsiql'


# This file contains the boilerplate needed to setup a small backend with our architecture.
#
# res is assumed to have a ctx object containing
# rid, uid, cid 	= request, user, customer id
# log 						= a log function that adds rid, uid, cid when loggnig to console
# transaction			= transaction helper to 
##############################################################################################################


# We want to be able to exit any api flow by throwing but we want to handle them gracefully,
# eg. a Validation or Permission error should not result in a 500 which is reserved for unhandled errors.
# export apiHandlerWrapper = (f) ->
# 	return (req, res) ->
# 		try
# 			result = f req, res
# 			res.json result
# 		catch err
# 			if err instanceof AuthError
# 				console.error err
# 				res.status(401).json(stringify(err))
# 			else if err instanceof ValidationError ||
# 							err instanceof FaultError ||
# 							err instanceof WeirdError ||
# 							err instanceof IntegrationError ||
# 							err instanceof PermissionError ||
# 							err instanceof DBError
# 				console.error err
# 				res.status(444).json(stringify(err))
# 			else
# 				console.error err
# 				throw err # throw any other kind so that nextjs error view in the browser works as expected


# We want to be able to exit any api flow by throwing but we want to handle them gracefully,
# eg. a Validation or Permission error should not result in a 500 which is reserved for unhandled errors.
handleError = (res, err) ->
	if err instanceof AuthError
		res.ctx.log.error err
		res.status(401).json(stringifyError(err)) # TODO change back to 401
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
		throw err # throw any other kind so that nextjs error view in the browser works as expected

# Always write rid, uid and cid from ctx so we can easily search and filter logs
export logger = (ctx, args...) ->
	console.log "!rid#{ctx.rid}!uid#{ctx.uid || ''}!cid#{ctx.cid || ''}!", args...

logger.error = (ctx, args...) ->
	console.error "!rid#{ctx.rid}!uid#{ctx.uid || ''}!cid#{ctx.cid || ''}!", args...

transaction = (pdb, ctx, fn) ->
	trans = await pdb.transaction ctx
	try
		await trans.begin()
		result = await fn trans
		await trans.commit()
		return result
	catch err
		await trans.rollback()
		throw err
	finally
		trans.release()

read = (pdb, ctx, query, unsafe = false, both = false) ->
	if unsafe then pdb.read.unsafe ctx, query
	else if both then pdb.read.normalized ctx, query
	else pdb.read ctx, query


# Lets you specify an endpoint in a succinct and unifrom way. Assumes you've set res.ctx 
export createEndpoint = (config, model) ->
	db = createDB {pool: config.pool, log: config.log || logger}

	pdb = createPDB
		db: db
		model: model
		log: config.log || logger
		safeGuard: (ctx, entity, asString) ->
			if asString
				if entity == 'Customer' then "id = #{ctx.cid}" else "cid = #{ctx.cid}"
			else
				if entity == 'Customer' then {id: ctx.cid} else {cid: ctx.cid}


	serverOps = createServerOps config.ops, pdb.psql

	return (spec, f, meta = {}) ->
		return (req, res) ->
			# if req.method != 'POST' then throw new Error 'Not correct'

			baseCtx = {rid: nanoid(), uid: undefined, cid: undefined}
			res.ctx = baseCtx
			res.ctx.log = (args...) -> logger baseCtx, args...
			res.ctx.log.error = (args...) -> logger.error baseCtx, args...
			res.ctx.transaction = (f) -> transaction pdb, baseCtx, f
			res.ctx.read = (query) -> read pdb, baseCtx, query
			res.ctx.read.unsafe = (query) -> read pdb, baseCtx, query, true
			res.ctx.read.normalized = (query) ->
				console.log 'read.normalized '
				read pdb, baseCtx, query, false, true
			res.ctx.write = (delta) ->
				# TODO: req.body.DELTA borde vara delta från argument?
				delta = $ req.body.DELTA, mapO (items, entity) ->
					return $ items, mapO (v, k) -> if isNil v then undefined else v

				trans = await db.transaction baseCtx

				try
					await trans.begin()
					exec = ({entity, id, op, delta}) ->
						if ! has entity, serverOps then throw new FaultError "No operations for entity '#{entity}'"
						if ! has op, serverOps[entity] then throw new FaultError "No operation '#{op}' for entity '#{entity}'"

						return serverOps[entity][op](baseCtx, trans.run, id, delta)

					serverDelta = await popsiql.query.runDelta {model, delta, exec}
					await trans.commit()
				catch err
					await trans.rollback()
					throw err
				finally
					trans.release()

				res.send serverDelta



			if isEmpty spec then f2 = (a) -> f a, res.ctx, req, res
			else f2 = func spec, (a) -> f a, res.ctx, req, res

			try
				await config.extendCtx req, res, meta
				result = await f2 req.body
				if result == undefined then # do nothing, f wants to handle response itself
				else if result == null then res.send 'null' # support sending nulls
				else if result.constructor.name == 'ServerResponse'
					# f is obsiously using res (ServerResponse) so assume it handles res.send ifself, i.e. do nothing here
				else res.json result
			catch err
				handleError res, err


# We might want to create a context in other places than for endpoints, eg. in getServerSideProps.
# Returns a ctx by creating and calling a fake endpoint.
# This is a test, not sure if it has too much negative impact on performance.
export createContext = (config, model, req, res) ->
	fakeEndpointF = createEndpoint config, model
	fakeApiF = (a, ctx, req, res) -> return ctx
	fakeApiEndpoint = fakeEndpointF {}, fakeApiF, {isPublic: false}
	res.json = (x) -> x
	ctx = await fakeApiEndpoint req, res
	return ctx


createServerOps = (def, psql) ->
	fns =
		create: (ctx, runSql, entity, op, id, delta) ->
			validateCtx ctx
			validateEntityId id
			validateDelta delta
			now = new Date()
			vals = $ delta, change {id: undefined, cid: ctx.cid, createdAt: now, updatedAt: now}
			[sql, params] = psql.insert {entity, values: vals}
			res = await runSql sql, params
			{id: newId} = res[0]
			serverDelta = {[entity]: {[id]: {id: newId}}}
			# logger ctx, serverDelta # swich to this for more detailed debugging
			return serverDelta

		update: (ctx, runSql, entity, op, id, delta) ->
			validateCtx ctx
			validateEntityId id
			validateDelta delta
			safeGuard = " and cid = #{ctx.cid}"
			now = new Date()
			vals = $ delta, change {id: undefined, createdAt: undefined, updatedAt: now}
			[sql, params] = psql.update {entity, id, values: vals, safeGuard}

			res = await runSql sql, params
			serverDelta = {}
			return serverDelta

		delete: (ctx, runSql, entity, op, id) ->
			validateCtx ctx
			validateEntityId id
			safeGuard = " and cid = #{ctx.cid}"
			[sql, params] = psql.delete {entity, id, safeGuard}

			res = await runSql sql, params
			serverDelta = {}
			return serverDelta



	return $ def, mapO (ops, entity) ->
		$ ops, mapO (conf, op) ->
			if has op, fns then return (ctx, runSql, ...args) ->
				defaultFn = () -> fns[op](ctx, runSql, entity, op, args...)
				if conf == 1 then return defaultFn()
				else conf ctx, defaultFn, args...
			else
				return (ctx, runSql, ...args) ->
					return con	f ctx, runSql, args...























