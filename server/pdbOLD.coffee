{empty, head, isNil, keys, length, match, omit, type, values} = R = require 'ramda' #auto_require: ramda
{$, isNilOrEmpty} = RE = require 'ramda-extras' #auto_require: ramda-extras
sutils = require '../shared/sharedUtils'
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

popsiql = require 'popsiql'

db = require './db'
# {log} = require './logger'
log = () -> console.log 'TODO'
# model = require './model'
{validateCtx, validateEntityId} = require './serverUtils'

toShortString = (x) ->
	if 'Array' == type x
		len = length x
		if len == 0 then return "[] (empty)"
		else if len == 1 then return "[ {} ] (1 item)"
		else if len == 2 then return "[ {}, {} ] (2 items)"
		else if len > 2 then return "[ {}, {}, ... ] (#{len} items)"
	else if 'Object' == type x
		return "{ id: #{x.id}, ... }"
	else
		return res

# psql = popsiql.sql model

# TODO: skriv exempel på in och ut data
extractFromArgs = (args, idRequired = false) ->
	if args.entity
		if idRequired
			if isNil args.id then throw Error 'id is required'
			return {entity: args.entity, values: args.values, id: args.id}
		return {entity: args.entity, values: args.values}

	entity = $ args, keys, head
	if !entity then throw new Error 'args in pdb needs to be exactly 1'
	values = $ args[entity], omit ['id']

	if idRequired
		if isNil args[entity].id then throw new Error 'id is required'
		return {entity, values, id: args[entity].id}
	else return {entity, values}


module.exports =
	read: (ctx, model, query) ->
		psql = popsiql.sql model
		execSql = (fatQuery) ->
			if isNil(ctx) || isNil(ctx.cid) then throw new ServerError 'ctx missing cid'

			if sutils.isEnvDev() && ctx.cid == -666 then safeGuard = null
			else safeGuard = if fatQuery.entity == 'Customer' then "id = #{ctx.cid}" else "cid = #{ctx.cid}"

			[sql, params] = psql.read fatQuery, safeGuard
			readRes = await db.run ctx, sql, params
			ctx.log toShortString readRes
			# log readRes # switch to this for more detailed debugging
			return readRes
		
		ctx.log popsiql.utils.queryToString query

		[result, normalized] = await popsiql.query.runQuery model, execSql, query
		return result

	transaction: (ctx, model) ->
		if isNilOrEmpty model then throw new Error 'model missing'
		psql = popsiql.sql model
		trans = await db.transaction ctx

		ret =
			begin: trans.begin
			commit: trans.commit
			rollback: trans.rollback
			release: trans.release
			runSql: trans.runSql
			read: (query) ->
				execSqlInTrans = (fatQuery) ->
					[sql, params] = psql.read fatQuery
					readRes = await trans.runSql sql, params
					log ctx, toShortString readRes
					# log readRes # swich to this for more detailed debugging
					return readRes.rows

				[result, normalized] = await popsiql.query.runQuery model, execSqlInTrans, query
				return result
			insert: (args) ->
				{entity, values} = extractFromArgs args
				validateCtx ctx
				newId = await trans.runSql.insert.apply null, psql.insert {entity, values: {...values, cid: ctx.cid}}
				return newId
			insert_unsafe: (args) ->
				{entity, values} = extractFromArgs args
				newId = await trans.runSql.insert.apply null, psql.insert {entity, values}
				return newId
			update: (args) ->
				{entity, id, values} = extractFromArgs args, true
				validateCtx ctx
				safeGuard = " and cid = #{ctx.cid}"
				validateEntityId id
				return trans.runSql.apply null, psql.update {entity, id, values, safeGuard}
			update_unsafe: (args) ->
				{entity, id, values} = extractFromArgs args, true
				validateEntityId id
				return trans.runSql.apply null, psql.update {entity, id, values}
			delete: (args) ->
				{entity, id} = extractFromArgs args, true
				validateCtx ctx
				safeGuard = " and cid = #{ctx.cid}"
				validateEntityId id
				return trans.runSql.apply null, psql.delete {entity, id, safeGuard}
			delete_unsafe: (args) ->
				{entity, id} = extractFromArgs args, true
				validateEntityId id
				return trans.runSql.apply null, psql.delete {entity, id, values}

		return ret


