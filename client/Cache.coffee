import equals from "ramda/es/equals"; import isNil from "ramda/es/isNil"; import match from "ramda/es/match"; import merge from "ramda/es/merge"; #auto_require: esramda
import {change} from "ramda-extras" #auto_require: esramda-extras
[ːPENDING] = ['PENDING'] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (args...) -> console.log args...
_ = (...xs) -> xs



export default class Cache
	constructor: (config) ->
		defaultConfig =
			initialState: {}
			runLocal: (query, state) -> throw new Error 'You must supply runLocal to Cache'
			runRemote: (query, localRes) -> throw new Error 'You must supply runRemote to Cache'
			resToId: (res) -> if res?.then then '[PROMISE]' else JSON.stringify res
			queryToId: JSON.stringify
			shouldRunRemote: (sub, res, state, remoteRun) -> if remoteRun?.then then remoteRun else !remoteRun
		@config = merge defaultConfig, config
		@subs = {}
		@subId = 0
		# @tempSubs = {}
		@state = @config.initialState
		@remoteRuns = {} # When remote query is running = promise. When finished = true


	# runOLD: (query) -> #, cb = undefined) ->
	# 	localRes = @config.runLocal query, @state
	# 	shouldRun = @config.shouldRunRemote query, localRes, @state, @remoteRuns[@config.queryToId query]
	# 	if shouldRun == true
	# 		promise = @config.runRemote(query).then (normData) => # No await because non-remote call should be sync
	# 			@remoteRuns[@config.queryToId query] = true
	# 			newRes = @config.runLocal query, normData
	# 			# cb? newRes
	# 			# @set normData
	# 			setTimeout (=> @set normData), 0 # offset so suspense can read data before we trigger set
	# 			return newRes
	# 		@remoteRuns[@config.queryToId query] = promise
	# 		return promise
	# 	else if shouldRun.then then return shouldRun
	# 	else return localRes


	runSub: (query) ->
		runRes = @run query
		if runRes?.then
			initialRes = ːPENDING
			Promise.resolve(runRes).then (res) ->
				initialRes = res
		else
			initialRes = runRes

		subCount = 0
		subscribe = (query2, cb) =>
			sub = {id: @subId++, query: query2, cb}
			@subs[sub.id] = sub
			if initialRes == ːPENDING && equals query, query2
				sub.pending = true
				runRes.then (res) =>
					sub.pending = false
					sub.lastResId = @config.resToId res
					# @_callSubIfNeeded sub.id, res

					# subRunRes = @run query2
					# if subRunRes?.then
					# 	sub.pending = true
					# 	subRunRes.then (res) =>
					# 		qq -> res
					# 		sub.pending = false
					# 		sub.lastResId = @config.resToId res
					# 		# @_callSubIfNeeded sub.id, res
					# 	sub.cb subRunRes
					# else
					# 	@_callSubIfNeeded sub.id, subRunRes
			else
				if subCount++ == 0
					sub.lastResId = @config.resToId initialRes
				subRunRes = @run query2
				if subRunRes?.then
					sub.pending = true
					subRunRes.then (res) =>
						sub.pending = false
						sub.lastResId = @config.resToId res
						# @_callSubIfNeeded sub.id, res
					sub.cb subRunRes
				else
					@_callSubIfNeeded sub.id, subRunRes


			return () => delete @subs[sub.id] 

		return [runRes, subscribe]

	# subSync: (query, cb) ->
	# 	res = @run query
	# 	sub = {id: @subId++, query, cb, lastResId: @config.lastResId res}
	# 	@subs[sub.id] = sub
	# 	@tempSubs[sub.id] = true
	# 	flip(setTimeout) 3000, => if @tempSubs[sub.id] then delete @subs[sub.id] | delete @tempSubs[sub.id]
	# 	update = (query) =>
	# 		if @temps[sub.id] then delete @tempSubs[sub.id]
	# 		if equals sub.query, query then return
	# 		newRes = @run query

	# 	unsub = => delete @subs[sub.id]
	# 	return [res, update, unsub]


	run: (query) ->
		localRes = @config.runLocal query, @state
		shouldRun = @config.shouldRunRemote query, localRes, @state, @remoteRuns[@config.queryToId query]
		if shouldRun == true
			pending = true
			promise = @config.runRemote(query).then (normData) => # No await because non-remote call should be sync
				@remoteRuns[@config.queryToId query] = true
				newRes = @config.runLocal query, normData
				# cb? newRes
				# @set normData
				@set normData, {quiet: true}
				setTimeout @_rerunSubs, 0 # offset so suspense can read data before we trigger set
				return newRes
			@remoteRuns[@config.queryToId query] = promise
			runRes = promise
			return promise
		else if shouldRun.then then return shouldRun
		else return localRes

	runLocal: (query) -> @config.runLocal query, @state

	_callSubIfNeeded: (subId, res) ->
		sub = @subs[subId]
		if !sub then return
		if sub.pending then return
		resId = @config.resToId res
		# console.log '_callSubIfNeeded', resId, sub.lastResId, resId != sub.lastResId
		if resId != sub.lastResId
			sub.lastResId = resId
			sub.cb res
		# else
		# 	qq -> 'k'

	# The concept is: First do a run and syncrounously get back data or promise.
	#									Second, do a sub and pass the lastRes from your previous run.
	# Known issue: if cache state changes between run and sub and both result in non-promises then you might
	# miss that change. So for no problems seen.
	# sub: (query, lastRes, cb) ->
	# 	# console.log 'Cache.sub', sf0(query), lastRes
	# 	sub = {id: @subId++, query, cb, lastResId: @config.resToId lastRes}
	# 	@subs[sub.id] = sub

	# 	return () => delete @subs[sub.id] 

	set: (delta, {quiet} = {quiet: false}) ->
		if isNil delta then throw new Error "Cache.set does not accept nil deltas"
		@state = change delta, @state
		@_handleIdChanges delta

		if !quiet then @_rerunSubs()

	_rerunSubs: () =>
		for subId, sub of @subs
			res = @config.runLocal sub.query, @state
			# console.log '_rerunSubs', sf0(sub.query), res, @state
			@_callSubIfNeeded subId, res

	reset: (newInitialState) ->
		@state = if newInitialState == undefined then @config.initialState else newInitialState
		@set {}
		@remoteRuns = {}

	_handleIdChanges: (delta) ->
		idChanges = []
		for entity, entityDelta of delta
			for id, objDelta of entityDelta
				if objDelta && !isNil(objDelta.id) && objDelta.id+'' != id+''
					idChanges.push [entity, id, objDelta.id]

		for [entity, oldId, newId] in idChanges
			currentData = @state[entity][oldId]
			@state = change {[entity]: {[oldId]: undefined, [newId]: currentData}}, @state

