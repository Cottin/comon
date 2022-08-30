import both from "ramda/es/both"; import empty from "ramda/es/empty"; import head from "ramda/es/head"; import isNil from "ramda/es/isNil"; import keys from "ramda/es/keys"; import length from "ramda/es/length"; import omit from "ramda/es/omit"; import type from "ramda/es/type"; import values from "ramda/es/values"; #auto_require: esramda
import {$, isNilOrEmpty} from "ramda-extras" #auto_require: esramda-extras

import popsiql from 'popsiql'


# Gives you an api to run popsiql queries against the supplied db object.
# eg. pdb = createPDB ...
#			pdb.read Customer: _ {status: 'demo'}
#
# Note: Lets you supply a ctx object if you need a more stateful execution
##############################################################################################################

export default createPDB = (config) ->
	db = config.db
	if !db then throw new Error 'db missing'

	log = config.log || (ctx, args...) -> console.log args...
	safeGuard = config.safeGuard || (ctx, entity, asString) -> if asString then '' else {}
	defaultValidateId = (ctx) -> if THIS_IS_WRONG_isNil(id) || isNaN(id) then throw new FaultError "invalid entity id: #{id}"
	validateId = config.validateId || defaultValidateId

	if isNilOrEmpty config.model then throw new Error 'model missing'
	psql = popsiql.sql config.model


	readF = (ctx, query, runF, both = false, unsafe = false) ->
		execSql = (fatQuery) ->
			safeGuardStr = if !unsafe then safeGuard ctx, fatQuery.entity, true
			[sql, params] = psql.read fatQuery, safeGuardStr
			readRes = await runF ctx, sql, params
			log ctx, toShortString readRes
			return readRes

		log ctx, popsiql.utils.queryToString query

		[result, normalized] = await popsiql.query.runQuery config.model, execSql, query
		return if both then [result, normalized] else result

	read = (ctx, query) -> readF ctx, query, db.run, false
	read.normalized = (ctx, query) ->
		console.log 'normalized', query
		readF ctx, query, db.run, true
	read.unsafe = (ctx, query) -> readF ctx, query, db.run, false, true

	# readTransF = (ctx, query, runF, )

	# eg. safeGuard = {cid: 123}
	transaction = (ctx) ->
		trans = await db.transaction ctx

		{begin, commit, rollback, release, run} = trans

		runTr = (__ctx, sql, params) -> run sql, params

		read = (query, safeGuard) -> readF ctx, query, runTr, false
		read.normalized = (query, safeGuard) -> readF ctx, query, runTr, true
		read.unsafe = (query) -> readF ctx, query, runTr, false, true

		insertF = (args, unsafe = false) ->
			{entity, values: vals} = extractFromArgs args
			safeGuardObj = safeGuard ctx, entity, false
			valuesData = if unsafe then vals else {...vals, ...safeGuardObj}
			newId = await run.insert.apply null, psql.insert {entity, values: valuesData}
			return newId

		insert_ = (args) -> insertF args, false
		insert_.unsafe = (args) -> insertF args, true

		updateF = (args, unsafe = false) ->
			{entity, id, values: vals} = extractFromArgs args, true
			validateId id
			valuesData = if unsafe then vals else {...vals, ...safeGuard}
			return await run.update.apply null, psql.update {entity, id, values: valuesData}

		update_ = (args) -> updateF args, false
		update_.unsafe = (args) -> updateF args, true

		removeF = (args, unsafe = false) ->
			{entity, id, values: vals} = extractFromArgs args, true
			validateId id
			valuesData = if unsafe then vals else {...vals, ...safeGuard}
			return await run.delete.apply null, psql.delete {entity, id, values: valuesData}

		remove_ = (args) -> removeF args, false
		remove_.unsafe = (args) -> removeF args, true

		return {begin, commit, rollback, release, run, read, insert: insert_, update: update_, remove: remove_}

	return {read, transaction, psql}


# Extracts entity and values to support both explicit and implicit usage
# extractFromArgs {entity: 'Customer', values: {name: 'Google Inc'}} # explicit
# extractFromArgs {Customer: {name: 'Google Inc'}} # implicit
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


# Entity specific string shortener
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
