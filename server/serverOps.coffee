{has, match, values} = R = require 'ramda' #auto_require: ramda
{change, mapO, $} = RE = require 'ramda-extras' #auto_require: ramda-extras
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

popsiql = require 'popsiql'

{IncorrectError: IE, WierdError: WE} = require './errors'
{log} = require './logger'
model = require './model'
{validateDelta, validateCtx, validateEntityId} = require './serverUtils'
psql = popsiql.sql(model)


# module.exports = () ->

	# createOps
	# 	Client:
	# 		create: 1
	# 		update: 1
	# 		delete: 1

	# 	Project:
	# 		create: 1
	# 		update: 1
	# 		delete: 1

	# 	Record:
	# 		create: 1
	# 		update: 1
	# 		delete: 1

	# 	Task:
	# 		create: 1
	# 		update: 1
	# 		delete: 1

	# 	User:
	# 		update: () ->

	# 	# App:
	# 	# 	setupNewUser: (ctx, runSql, args) ->
	# 	# 		{firebaseId, email} = args
	# 	# 		if !firebaseId || !email then throw new IE "missing firebaseId (#{firebaseId}) or email (#{email})"
	# 	# 		createdAt = updatedAt = new Date()
	# 	# 		custId = await runSql.insert psql.insert {entity: 'Cust', values: {createdAt, updatedAt}}
	# 	# 		if !custId then throw new IE "did not get valid custId after insert"
	# 	# 		alreadyExistRes = await runSql.query User: _ {OR: [{firebaseId}, {email}]}
	# 	# 		if !isEmpty alreadyExistRes
	# 	# 			throw new WE "cannot setup, user already exists (#{firebaseId}, #{email})"
	# 	# 		userId = await runSql.insert psql.insert {entity: 'User', values: {firebaseId, email, custId,
	# 	# 		createdAt, updatedAt}}
	# 	# 		return {a: 'hej'}




module.exports = (def) ->
	fns =
		create: (ctx, runSql, entity, op, id, delta) ->
			validateCtx ctx
			validateEntityId id
			validateDelta delta
			now = new Date()
			values = $ delta, change {id: undefined, cid: ctx.cid, createdAt: now, updatedAt: now}
			[sql, params] = psql.insert {entity, values}
			res = await runSql sql, params
			{id: newId} = res.rows[0]
			serverDelta = {[entity]: {[id]: {id: newId}}}
			log ctx, serverDelta # swich to this for more detailed debugging
			return serverDelta

		update: (ctx, runSql, entity, op, id, delta) ->
			validateCtx ctx
			validateEntityId id
			validateDelta delta
			safeGuard = " and cid = #{ctx.cid}"
			now = new Date()
			values = $ delta, change {id: undefined, createdAt: undefined, updatedAt: now}
			[sql, params] = psql.update {entity, id, values, safeGuard}

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



	$ def, mapO (ops, entity) ->
		$ ops, mapO (conf, op) ->
			if has op, fns then return (ctx, runSql, ...args) ->
				defaultFn = () -> fns[op](ctx, runSql, entity, op, args...)
				if conf == 1 then return defaultFn()
				else conf ctx, defaultFn, args...
			else
				return (ctx, runSql, ...args) ->
					return con	f ctx, runSql, args...



