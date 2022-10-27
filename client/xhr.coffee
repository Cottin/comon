import match from "ramda/es/match"; import none from "ramda/es/none"; import path from "ramda/es/path"; import test from "ramda/es/test"; #auto_require: esramda
import {} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

import * as utils from './clientUtils'
import {parseError} from '../shared/errors'

please = "Couldn't reach server. Please check your connection and try again."
please500 = "Something did not work... We're sorry, please contact support."

export default xhr = ({popsiqlUrl, restUrl, on401}) ->
	popsiqlApi:
		post: (remoteQuery) ->
			token = undefined #utils.getCookie('CSRF-TOKEN')
			res = await fetch popsiqlUrl,
				credentials: 'same-origin'
				# credentials: 'include'
				method: 'POST'
				headers: {'Content-Type': 'application/json', 'CSRF-Token': token}
				body: JSON.stringify remoteQuery, (k, v) -> if v == undefined then null else v

			if res.status == 401
				if ! test /\/login|\/logout/, location.pathname then on401()
					# location.href = "/login?redirect=#{encodeURIComponent(location.pathname+location.search)}"
			else if res.status >= 200 && res.status < 400
				return res.json()
			else if res.status == 444
				err = await res.json()
				throw parseError err
			else if res.status == 500
				text = await res.text()
				throw new Error "Popsiql(500)!" + text
			else
				throw new Error "XHR(Popsiql)!" + please

	restApi:
		post: (path, body, {responseType, fileName} = {}) ->
			token = undefined # utils.getCookie('CSRF-TOKEN')
			res = await fetch restUrl + path,
				credentials: 'same-origin'
				# credentials: 'include'
				method: 'POST'
				headers: {'Content-Type': 'application/json', 'CSRF-Token': token}
				body: JSON.stringify body

			if res.status == 401
				if ! test /\/login|\/logout/, location.pathname
					on401()
					return undefined
					# location.href = "/login?redirect=#{encodeURIComponent(location.pathname+location.search)}"
					# return undefined
			else if res.status >= 200 && res.status < 400
				if responseType == 'blob'
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
				else return res.json()
			else if res.status == 444
				ourError = await res.json()
				throw new Error ourError.message
			else if res.status == 500
				text = await res.text()
				throw new Error please500
			else
				throw new Error please

		get: (path, {responseType, fileName} = {}) ->
			token = undefined #utils.getCookie('CSRF-TOKEN')
			res = await fetch restUrl + path,
				credentials: 'same-origin'
				# credentials: 'include'
				method: 'GET'
				headers: {'Content-Type': 'application/json', 'CSRF-Token': token}

			if res.status == 401
				if ! test /\/login|\/logout/, location.pathname
					on401()
					# location.href = "/login?redirect=#{encodeURIComponent(location.pathname+location.search)}"
					return undefined
			else if res.status >= 200 && res.status < 400
				if responseType == 'blob'
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
				else return res.json()
			else if res.status == 444
				text = await res.text()
				throw new Error "Rest(444)!" + text
			else if res.status == 500
				text = await res.text()
				throw new Error "Rest(500)!" + text
			else
				throw new Error "XHR-Rest(#{res.status})!" + please

