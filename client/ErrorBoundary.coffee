import match from "ramda/es/match"; import props from "ramda/es/props"; #auto_require: esramda
import {} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

import React from "react"


export default class ErrorBoundary extends React.Component
	constructor: (props) ->
		super props
		@state = {hasError: false, error: null}

	@getDerivedStateFromError: (error) ->
		return {hasError: true, error}

	componentDidCatch: (error, errorInfo) ->
		console.log error
		console.log errorInfo
		# log error if you want

	reset: () ->
		@setState {hasError: false, error: null}

	render: () ->
		if @state.hasError
			# return _ {}, 'Something went wrong. TODO: Använd ErrorPanel av något slag'
			return @props.onError @state.error, @reset

		return @props.children
