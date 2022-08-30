import always from "ramda/es/always"; import clone from "ramda/es/clone"; import init from "ramda/es/init"; import match from "ramda/es/match"; import merge from "ramda/es/merge"; import omit from "ramda/es/omit"; import type from "ramda/es/type"; #auto_require: esramda
import {isNilOrEmpty, PromiseProps, sf0} from "ramda-extras" #auto_require: esramda-extras
[ːABORT, ːextend] = ['ABORT', 'extend'] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (args...) -> console.log args...
_ = (...xs) -> xs

import React from 'react'
import popsiql from "popsiql"


hasPromise = (o) ->
	for k, v of o
		if v?.then then return true
	return false

# https://dev.to/andreiduca/practical-implementation-of-data-fetching-with-react-suspense-that-you-can-use-today-273m

wrapPromise = (promise) ->
	[data, status, error] = [null, 'init', null]

	suspender = promise
		.then (result) ->
			data = result
			status = 'done'
		.catch (err) ->
			error = err
			status = 'error'

	return () ->
		if status == 'init' then throw suspender
		else if status == 'error' then throw error
		else
			return data

createReader = (promiseOrData) ->
	if !promiseOrData.then then () -> promiseOrData
	else wrapPromise promiseOrData

updateKandCreateReader = (k, val, prevReader) ->
	try
		data = prevReader()
		if val?.then
			newPromise = val.then (resVal) -> {...data, [k]: resVal}
			return createReader newPromise
		else
			return createReader {...data, [k]: val}
	catch promiseOrError
		if promiseOrError.then
			if val?.then
				combinedPromise = Promise.all([promiseOrError, val]).then ([prevReaderFinished, resVal]) ->
					data = prevReader()
					return {...data, [k]: resVal}
				return createReader combinedPromise
			else
				alteredPromise = promiseOrError.then (prevReaderFinished) ->
					data = prevReader()
					return {...data, [k]: val}
				return createReader alteredPromise






export default createHooks = ({run, sub, runSub, updateCache}) ->

	useApp = (query) ->
		uiQuery = UI: _ (query.UI?[0] || {}), (query.UI?[1] || {})
		if query.Url then uiQuery.UI[1].url = query.Url

		ui = useUI uiQuery.UI[0], uiQuery.UI[1]
		data = useData query.Data || {}

		return {ui: omit(['url'], ui), url: ui?.url, data}

	useData = (queryMap) ->
		popsiql.utils.ensureQueryMap queryMap
		subscribe = React.useRef({})
		[reader, updateReader] = React.useState () ->
			if isNilOrEmpty queryMap then return () -> {}

			res = {}
			for k, query of queryMap
				[kres, ksub] = runSub query
				res[k] = kres
				subscribe.current[k] = ksub

			if hasPromise res
				unifiedPromise = PromiseProps res
				reader = wrapPromise unifiedPromise
				reader.query = queryMap
				return reader
			else return () -> res

		React.useEffect () ->
			if isNilOrEmpty queryMap then return () -> # noop

			cb = (k) -> (promiseOrData) ->
				try
					updateReader (prevReader) ->
						reader = updateKandCreateReader k, promiseOrData, prevReader
						reader.query = queryMap
						return reader
					# currentData = reader()
					# newData = change {[k]: promiseOrData}, currentData
					# console.log 'useData cb', sf0(queryMap), currentData, newData
					# if equals newData, currentData then return
					# console.log '...update!'
					# updateReader () -> () -> newData
				catch suspenderOrError
					console.log "cb called during suspenderOrError: #{suspenderOrError}, #{k}: #{sf0 promiseOrData}"

			unsubs = []
			for k, q of queryMap
				unsub = subscribe.current[k] q, cb(k)
				unsubs.push unsub

			return () ->
				for unsub in unsubs then unsub()
		, [JSON.stringify queryMap]

		return reader

	useUI = (query, childQuery) ->
		uiQuery = popsiql.utils.toDataQuery UI: _ query, childQuery

		subscribe = React.useRef()
		[state, setState] = React.useState () ->
			[res, subscribe.current] = runSub uiQuery
			return res

		React.useEffect () ->
			cb = (data) ->
				# console.log 'useUI cb ', sf0(query), sf0(data)
				setState data
			return subscribe.current uiQuery, cb
		, [JSON.stringify uiQuery]

		return state.UI

	useVM = useViewModel = (res, query) ->
		dataQuery = popsiql.utils.toDataQuery query
		return subSelectIfDEV(dataQuery, {VM: res}).VM


	_useCall = (optionsOrCall, callOrUndefined) ->
		isMounted = React.useRef true
		isMountedGuard isMounted

		serverCall = optionsOrCall
		options = {isPopsiql: false, successDelay: 1500}
		if type(optionsOrCall) == 'Object' 
			options = {...options, ...optionsOrCall}
			serverCall = optionsOrCall.call || callOrUndefined

		[s, cs] = useChangeState {}

		serverCallF = (args...) ->
			cs {wait: true, error: undefined, result: undefined}
			try
				result = await Promise.resolve serverCall args...
				if result == ːABORT
					cs {wait: false}
					return result
				if options.isPopsiql then updateCache result.normDelta
				if !isMounted.current then return result
				cs {wait: false, success: true, result}
				if options.successDelay > 0 then setTimeout (->
					if !isMounted.current then return result
					cs {success: undefined}), options.successDelay

				return result
			catch error
				options.onError?(error)
				cs always {error, wait: false}
				console.error error

		return 
			wait: s.wait
			result: s.result
			error: s.error
			success: s.success
			reset: (key = undefined) ->
				if key && type(key) == 'string' && !s.error?.meta?[key] then return
				cs always {}
			call: serverCallF
					# when ːextend then (f) -> 

	useCall = (optionsOrCall, callOrUndefined) ->
		_useCall optionsOrCall, callOrUndefined


	useEdit = ({data = {}, save, postSave = (->), options = {}}) ->
		isMounted = React.useRef true
		isMountedGuard isMounted

		opts = {isPopsiql: true, successDelay: 1500, ...options}
		initialState = (data) -> {status: {hot: false}, copy: clone(data), delta: {}, currentData: data}
		[s, cs] = useChangeState initialState data

		useDidUpdateEffect () ->
			cs always initialState data
		, [sf0 data]

		status: s.status
		edit:
			start: () -> cs {status: always({edit: true, hot: false})}
			cancel: () -> cs {status: always({hot: false}), copy: always(clone(s.currentData))}
			save: () ->
				cs {status: {edit: true, wait: true, error: undefined, hot: true}}
				try
					result = await save {data: s.copy, delta: s.delta}
					if opts.isPopsiql
						updateCache result.normDelta
						newData = merge s.copy, result.delta
						oldData = {...s.copy}
						if !isMounted.current
							postSave {oldData, newData}
							return {oldData, newData}
						cs {currentData: newData, copy: newData, delta: {}, error: null,
						status: always({success: true, hot: false})}
						if opts.successDelay > 0 then setTimeout (->
							if !isMounted.current
								postSave {oldData, newData}
								return {oldData, newData}
							cs {status: {success: undefined}}), 1500
						postSave {oldData, newData}
						return {oldData, newData}
					else
						# Note: currentData and copy not updated, i.e. you need to updateManually if not popsiql
						cs {delta: {}, error: null, status: always({success: true, hot: false})}
						if opts.successDelay > 0 then setTimeout (->
							if !isMounted.current
								postSave result
								return result
							cs {status: {success: undefined}}), 1500
						postSave result
						return result
					# 	if result?.data then newData = result.data 
					# 	else if result?.delta then newData = merge(s.copy, result.delta)
					# 	else newData = merge(s.copy, {})

					# oldData = {...s.copy}
					# cs {currentData: newData, copy: newData, delta: {}, error: null,
					# status: always({success: true})}
					# if opts.successDelay > 0 then setTimeout (-> cs {status: {success: undefined}}), 1500
					# return {oldData, newData}
				catch err
					cs {status: always({edit: true, error: err, hot: true})}
					console.error err

			change: (newDelta) -> cs {delta: merge(s.delta, newDelta), copy: merge(s.copy, newDelta)}
			updateManually: (newData) -> cs {currentData: newData, copy: newData, delta: {}}
			resetStatus: () -> cs {status: always({hot: false})}
		copy: s.copy

	return {useApp, useEdit, useCall}



