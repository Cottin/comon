import _test from "ramda/es/test"; #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras
_ = (...xs) -> xs

import * as utils from './clientUtils'
import {parseError} from '../shared/errors'

defaults =
	check: "Couldn't reach server. Please check your connection and try again."
	500: "An unknown error has occurred"

replacer = (key, value) ->
	return if value == undefined then '__UNDEFINED_$%&_' else value

export default xhr = ({popsiqlUrl, restUrl, on401, please500 = defaults['500'], pleaseCheck = defaults.check}) ->
	rest = ({path, method, body, responseType = null, fileName = null, rawBody = false, signal = null}) ->
			token = undefined # utils.getCookie('CSRF-TOKEN')
			params = 
				credentials: 'same-origin'
				# credentials: 'include'
				method: method
				signal: signal

			if rawBody then params.headers = {'CSRF-Token': token}
			else params.headers = {'Content-Type': 'application/json', 'CSRF-Token': token}

			if method == 'POST'
				params.body = if rawBody then body else JSON.stringify body, replacer
			console.log 'is signal aborted before the fetch:', signal
			res = await fetch restUrl + path, params

			if res.status == 401
				# If we're not on a login page we should probably redirect to one
				if ! _test(/\/login/, location.pathname)
					on401()
					return undefined
				else
					# If we are on a login page and calling a login endpoint, we're probably interested in the error
					if _test(/\/login/, path)
						ourError = await res.json()
						throw new Error ourError.message
					return undefined

			else if res.status >= 200 && res.status < 400
				if responseType == 'blob'
					return handleFileDownload res, fileName
				else return res.json()
			else if res.status == 444
				ourError = await res.json()
				throw parseError ourError
			else if res.status == 500
				text = await res.text()
				console.log 'text', text
				throw new Error text
			else
				throw new Error pleaseCheck
		

	pop = (query, isRead) ->
			token = undefined #utils.getCookie('CSRF-TOKEN')
			url = "#{popsiqlUrl}/#{isRead && 'read' || 'write'}"
			res = await fetch url,
				credentials: 'same-origin'
				# credentials: 'include'
				method: 'POST'
				headers: {'Content-Type': 'application/json', 'CSRF-Token': token}
				body: JSON.stringify query, (k, v) -> if v == undefined then null else v

			if res.status == 401
				if ! _test /\/login/, location.pathname then on401()
			else if res.status >= 200 && res.status < 400
				return res.json()
			else if res.status == 444
				err = await res.json()
				throw parseError err
			else if res.status == 500
				text = await res.text()
				console.error text 
				throw new Error please500
			else
				throw new Error pleaseCheck

	popsiqlApi:
		read: (query) -> pop query true
		write: (query) -> pop query, false

	restApi:
		post: (path, body, {responseType, fileName, rawBody, signal} = {}) ->
			rest {path, method: 'POST', body, responseType, fileName, rawBody, signal}
		get: (path, {responseType, fileName} = {}) -> rest {path, method: 'GET', responseType, fileName}


handleFileDownload = (res, fileName) ->
	# https://stackoverflow.com/a/9970672/416797
	blob = await res.blob()
	url = window.URL.createObjectURL blob
	a = document.createElement 'a'
	a.style.display = 'none'
	a.href = url
	a.download = fileName
	document.body.appendChild a
	a.click()
	window.URL.revokeObjectURL url
	return undefined
