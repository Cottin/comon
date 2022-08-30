import both from "ramda/es/both"; import head from "ramda/es/head"; import insert from "ramda/es/insert"; import isNil from "ramda/es/isNil"; import keys from "ramda/es/keys"; import omit from "ramda/es/omit"; import remove from "ramda/es/remove"; import update from "ramda/es/update"; import values from "ramda/es/values"; #auto_require: esramda
import {$, isNilOrEmpty} from "ramda-extras" #auto_require: esramda-extras

import popsiql from 'popsiql'

import db from './db'


createPDB = (config) ->
	log = config.log || console.log
	safeGuard = config.safeGuard || () -> {}
	defaultValidateId = () -> if isNil(id) || isNaN(id) then throw new FaultError "invalid entity id: #{id}"
	validateId = config.validateId || defaultValidateId

	if isNilOrEmpty config.model then throw new Error 'model missing'
	psql = popsiql.sql config.model


	readF = (query, safeGuard, runF, both = false) ->
		execSql = (fatQuery) ->
			[sql, params] = psql.read fatQuery, safeGuard
			readRes = await runF sql, params
			log readRes
			return readRes

		log popsiql.utils.queryToString query

		[result, normalized] = await popsiql.query.runQuery model, execSql, query
		return if both then [result, normalized] else result

	read = (query, safeGuard) -> readF query, safeGuard, db.run, false
	read.normalized = (query, safeGuard) -> readF query, safeGuard, db.run, true

	# eg. safeGuard = {cid: 123}
	transaction = (safeGuard = {}) ->
		trans = await db.transaction ctx

		{begin, commit, rollback, release, run} = trans

		read = (query, safeGuard) -> readF query, safeGuard, run, false
		read.normalized = (query, safeGuard) -> readF query, safeGuard, run, true

		insertF = (args, unsafe = false) ->
			{entity, values} = extractFromArgs args
			valuesData = if unsafe then values else {...values, ...safeGuard}
			newId = await run.insert.apply null, psql.insert {entity, values: valuesData}
			return newId

		insert = (args) -> insertF args, false
		insert.unsafe = (args) -> insertF args, true

		updateF = (args, unsafe = false) ->
			{entity, id, values} = extractFromArgs args, true
			validateId id
			valuesData = if unsafe then values else {...values, ...safeGuard}
			return await run.update.apply null, psql.update {entity, id, values: valuesData}

		update = (args) -> updateF args, false
		update.unsafe = (args) -> updateF args, true

		removeF = (args, unsafe = false) ->
			{entity, id, values} = extractFromArgs args, true
			validateId id
			valuesData = if unsafe then values else {...values, ...safeGuard}
			return await run.delete.apply null, psql.delete {entity, id, values: valuesData}

		remove = (args) -> removeF args, false
		remove.unsafe = (args) -> removeF args, true

		return {begin, commit, rollback, release, run, insert, update, remove}


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
