import _length from "ramda/es/length"; import _type from "ramda/es/type"; #auto_require: _esramda
import {isNilOrEmpty, sf2} from "ramda-extras" #auto_require: esramda-extras

import {popsiql, popSql} from 'popsiql'




# Gives you an api to run popsiql queries against the supplied db object and lets you supply a ctx object
# eg. pdb = createPDB ...
#			pdb.read customer: _ {status: {eq: 'demo'}}
#
# Note: This is pure glue code
##############################################################################################################

export default createPDB = (config) ->
	db = config.db
	if !db then throw new Error 'db missing'
	if isNilOrEmpty config.model then throw new Error 'model missing'

	parse = popsiql config.model
	psql = popSql parse


	defaultRunner = curry (ctx, sql, params) -> db.run ctx, sql, params

	readF = (ctx, query, runner, both = false, unsafe = false) ->
		ctx.log popsiql.utils.queryToString query

		safeGuard = if !unsafe then config.safeGuards.read ctx

		if both
			[res, normRes] = await psql query, {result: 'both', runner, safeGuard}
			ctx.log toShortString res
			return [res, normRes]
		else
			res = await psql query, {runner, safeGuard}
			ctx.log toShortString res
			return res

	writeF  = (ctx, delta, runner, unsafe = false) ->
		ctx.log sf2 delta

		safeGuard = if !unsafe then config.safeGuards.write ctx

		res = await psql.write delta, {runner, safeGuard}
		return {}


	getTransaction = (ctx) ->
		trans = await db.transaction ctx

		{begin, commit, rollback, release, run} = trans

		runner = (sql, params) -> run sql, params

		read = (query) -> readF ctx, query, runner, false, false
		read.normalized = (query) -> readF ctx, query, runner, true, false
		read.unsafe = (query) -> readF ctx, query, runner, false, true
		read.unsafeNormalized = (query) -> readF ctx, query, runner, true, true

		write = (delta) -> writeF ctx, delta, runner, false
		write.unsafe = (delta) -> writeF ctx, delta, runner, true

		return {begin, commit, rollback, release, run, read, write}

	makeTransaction = (ctx) -> (fn) ->
		tr = await getTransaction ctx
		try
			await tr.begin()
			result = await fn {read: tr.read, write: tr.write, run: tr.run}
			await tr.commit()
			return result
		catch err
			await tr.rollback()
			throw err
		finally
			tr.release()

	# Given a ctx returns a ctx dependent api to interact with pdb
	makeApi = (ctx) ->
		read = (query) -> readF ctx, query, defaultRunner(ctx), false, false
		read.normalized = (query) -> readF ctx, query, defaultRunner(ctx), true, false
		read.unsafe = (query) -> readF ctx, query, defaultRunner(ctx), false, true
		read.unsafeNormalized = (query) -> readF ctx, query, defaultRunner(ctx), true, true

		write = (delta) -> writeF ctx, delta, defaultRunner(ctx), false
		write.unsafe = (delta) -> writeF ctx, delta, defaultRunner(ctx), true

		transaction = makeTransaction ctx

		return {read, write, transaction}

	# Read function to use before makeApi has been called
	readCtxUnsafe = (ctx, query) -> readF ctx, query, defaultRunner(ctx), false, true

	return {makeApi, readCtxUnsafe}


# Entity specific string shortener
toShortString = (x) ->
	if 'Array' == _type x
		len = _length x
		if len == 0 then return "[] (empty)"
		else if len == 1 then return "[ {} ] (1 item)"
		else if len == 2 then return "[ {}, {} ] (2 items)"
		else if len > 2 then return "[ {}, {}, ... ] (#{len} items)"
	else if 'Object' == _type x
		return "{ id: #{x.id}, ... }"
	else
		return x
