import gt from "ramda/es/gt"; import head from "ramda/es/head"; import keys from "ramda/es/keys"; import length from "ramda/es/length"; import replace from "ramda/es/replace"; import test from "ramda/es/test"; import values from "ramda/es/values"; #auto_require: esramda
import {$} from "ramda-extras" #auto_require: esramda-extras
_ = (...xs) -> xs

import popsiql from "popsiql"

import Cache from "./Cache"
import createAppHooks from "./createAppHooks"


sleep = (ms) -> new Promise (resolve) -> setTimeout(resolve, ms)

isLocal = (query) -> $ query, keys, head, test(/LO$/)
removeLO = (query) ->
	if isLocal query then {[$(query, keys, head, replace(/LO$/, ''))]: $(query, values, head)}
	else query

export default class App
	constructor: (config) ->
		defaultConfig =
			initialUI: {}
			runRemote: () -> throw new Error 'Must supply runRemote to App'
		@config = {...defaultConfig, ...config}

		@cache = new Cache
			runLocal: @_runLocal
			runRemote: @config.runRemote
			shouldRunRemote: (query, res, state, remoteRun) ->
				if query.UI then false
				else if isLocal query then false
				else if remoteRun?.then then remoteRun
				else !remoteRun
			initialState: {UI: @config.initialUI}

		@ops = {} # set yourself

		@hooks = createAppHooks {run: @run, sub: @sub, runSub: @runSub, updateCache: @setCache}

	_runLocal: (query, state) => 
		if query.UI
			[missing, subData] = popsiql.utils.subSelect query, state
			return subData
		else
			query_ = removeLO query
			popsiqlRamda = popsiql.ramda @config.model, state
			ramdaRead = (fatQuery) =>
				popsiqlRamda.read fatQuery, (entity, id, o) => o
			fatQuery = popsiql.query.expandQuery @config.model, query_
			[res, normRes] = popsiql.query.runFatQuerySync @config.model, ramdaRead, fatQuery, query_
			return res

	sub: (query, cb, options) =>
		if query.UI && $ query, keys, length, gt(1)
			throw new Error "App.sub only allows UI queries alone: #{JSON.stringify query}"
		return @cache.sub query, cb, options

	run: (query) => @cache.run query
	runSub: (query) => @cache.runSub query
	setUI: (delta) => @cache.set {UI: delta}
	setCache: (normDelta) => @cache.set normDelta




