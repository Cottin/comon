import _fromPairs from "ramda/es/fromPairs"; import _init from "ramda/es/init"; import _isEmpty from "ramda/es/isEmpty"; import _isNil from "ramda/es/isNil"; import _join from "ramda/es/join"; import _last from "ramda/es/last"; import _length from "ramda/es/length"; import _map from "ramda/es/map"; import _path from "ramda/es/path"; import _pickBy from "ramda/es/pickBy"; import _reject from "ramda/es/reject"; import _replace from "ramda/es/replace"; import _split from "ramda/es/split"; import _test from "ramda/es/test"; import _toPairs from "ramda/es/toPairs"; import _type from "ramda/es/type"; #auto_require: _esramda
import {change, $, isNotNil} from "ramda-extras" #auto_require: esramda-extras

import React from 'react'
import {sleep} from '../shared/sharedUtils'

# Shared utils
# TODO: figure out way to add all from sharedUtils


########## UTILS #############################################################################################
export capitalize = (s) -> s.charAt(0).toUpperCase() + s.slice(1)

export equalsAt = (pathStr, o1, o2) ->
	spaths = _split ',', pathStr
	for spath in spaths
		p = _split '.', spath
		if _last(p) == '*'
			p_ = _init p
			o1p = _path p_, o1
			o2p = _path p_, o2
			console.log o1p, o2p
			for k,v of o1p
				if o2p[k] != v then return false
		else
			if _path(p, o1) != _path(p, o2) then return false

	return true

export emptyIfNil = (x) -> if _isNil x then '' else x

export cutTextAt = (n, s) ->
	if _isNil s then ''
	else if _length(s) > n then s.substr(0, n) + '...'
	else return s

export toHMM = (n) ->
	if _isNil n then return null
	h = toH n
	mm = toMM n
	return "#{h}:#{mm}"

export toH = (n) -> Math.trunc n

export toMM = (n) ->
	decimalPart = n % 1
	m = Math.round decimalPart * 60
	if m < 10 then '0' + m else m

export onlyInteger = (n) -> Math.trunc n
export onlyDecimal = (n) -> $ n.toFixed(2), toStr, _replace(/.*\./, '.')

export flattenEntity = (o) ->
	res = {}
	for k, v of o
		switch _type v
			when 'Null', 'String', 'Number', 'Boolean' then res[k] = v
			when 'Object' then res["#{k}Id"] = v.id
			else throw new Error 'NYI'
	return res

# Sometimes an call to the server can be too fast resulting in a blinking UI.
# This assures that an async call takes minimum the supplied delay so spinners have time to render
export minDelay = (delay, promise) ->
	start = performance.now()
	res = await promise
	delta = delay - (performance.now() - start)
	if delta > 0 then await sleep delta
	return res

########## BROWSER ###########################################################################################
export keyCodes =
	ENTER: 13
	ESC: 27
	UP: 38
	DOWN: 40
	TAB: 9
	SPACE: 32

# Calculates the mouse offset from target element (or any element you supply).
# Helper since this is quite a common task.
export getMouseOffset = (e, element = null) ->
	rect = (element || e.target).getBoundingClientRect()
	offsetTop = e.clientY - rect.top
	offsetLeft = e.clientX - rect.left
	offsetBottom = rect.bottom - e.clientY
	offsetRight = rect.left - e.clientX
	return [offsetTop, offsetRight, offsetBottom, offsetLeft]

# https://www.w3schools.com/js/js_cookies.asp
export getCookie = (cname) ->
	name = cname + '='
	decodedCookie = decodeURIComponent(document.cookie)
	ca = decodedCookie.split(';')
	i = 0
	while i < ca.length
		c = ca[i]
		while c.charAt(0) == ' '
			c = c.substring(1)
		if c.indexOf(name) == 0
			return c.substring(name.length, c.length)
		i++
	return ''

export isTouch = () -> window.matchMedia("(pointer: coarse)").matches

# Adapted from https://stackoverflow.com/a/7557433/416797
export elementViewportOffset = (el) ->
	if _isNil el then return {top: 0, right: 0, bottom: 0, left: 0}
	rect = el.getBoundingClientRect()

	return 
		top: rect.top
		right: (window.innerWidth || document.documentElement.clientWidth) - rect.right
		bottom: (window.innerHeight || document.documentElement.clientHeight) - rect.bottom
		left: rect.left


# Optimistically parses to Number or Boolean if needed
export autoParseUrl = (val) ->
	# disabling temporarily since mixing '102', and 'asldkjaslkd' ids in time and I'm tired.
	# Real solution probably to clean up ids in test cus it's not obvious if there's an easy way of handling
	# mixing of numbers and strings.
	# if !isNaN(val) then Number(val) 
	if val == 'true' then true
	else if val == 'false' then false
	else if _test(/^\[.*\]$/, val) # arrays eg. "[1, 2]" --> [1, 2]
		if val == '[]' then []
		else $ val[1...val.length-1], _split(','), _map autoParseUrl
	else val

kvToQuery = ([k, v]) ->
	if _type(v) == 'Array'
		if _isEmpty v then ""
		else "#{k}=[#{$ v, _join(',')}]"
	else "#{k}=#{v}"


# Parses url string to object
# eg. '/p/q/r?a=1&b=2' -> {path0: 'p', path1: 'q', path2: 'r', a: 1, b: 2}
export fromUrl = (url) ->
	[pathStr, queryStr] = $ url, _replace(/^\//, ''), _split '?'
	[path0, path1, path2, path3, path4] = if _isEmpty pathStr then [] else _split '/', pathStr
	qs = $ queryStr || '', _split('&'), _map(_split('=')), _fromPairs

	return $ {path0, path1, path2, path3, path4, ...qs}, _pickBy(isNotNil), _map(autoParseUrl)

# Stringifies a query object to a url string
# eg. {path0: 'p', path1: 'q', path2: 'r', a: 1, b: 2}' -> /p/q/r?a=1&b=2'
export toUrl = (query) ->
	{path0, path1, path2, path3, path4, ...rest} = query
	paths = $ [path0, path1, path2, path3, path4], _reject(_isNil), _join '/'
	queryStr = if _isEmpty rest then '' else "?" + $ rest, _toPairs, _map(kvToQuery), _join '&'
	return "#{if paths == '' then '' else '/' + paths}#{queryStr}"

# Convenience function to interact with next.js router in "our" way. Use with either router or Router
# Supply a post function if any post processing is needed after spec is applied
export navigate = (routerOrRouter, spec, options = {scroll: false, shallow: true}, post = null) ->
	asPath = routerOrRouter.asPath || routerOrRouter.router?.state?.asPath
	urlQuery = fromUrl asPath
	newQuery = change spec, urlQuery
	newPostQuery = if post then post newQuery else newQuery
	newUrl = toUrl newPostQuery
	routerOrRouter.push newUrl, null, options

export prepareNavigate = (routerOrRouter, spec, post = null) ->
	asPath = routerOrRouter.asPath || routerOrRouter.router?.state?.asPath
	# NOTE: On server: projects=%5B5%2C101%5D  On client: projects=[5,101] 
	#				Generates "Warning: Prop `href` did not match" in next js
	# 			Solution below is to always decode the asPath (decoding projects=[5,101] returns projects=[5,101])
	decodedAsPath = decodeURIComponent asPath
	urlQuery = fromUrl decodedAsPath
	newQuery = change spec, urlQuery
	newPostQuery = if post then post newQuery else newQuery
	newUrl = toUrl newPostQuery
	return newUrl


########## SPECIALS ##########################################################################################

# Light weight way of getting some password strength
# Probably better option is https://github.com/dropbox/zxcvbn but its 400kB so would probably need server-side
# implementation = overkill right now.
# https://stackoverflow.com/a/11268104/416797
export scorePassword = (pass) ->
	score = 0
	if !pass then return score
	# award every unique letter until 5 repetitions
	letters = {}
	i = 0
	while i < pass.length
		letters[pass[i]] = (letters[pass[i]] or 0) + 1
		score += 5.0 / letters[pass[i]]
		i++
	# bonus points for mixing it up
	variations = 
		digits: /\d/.test(pass)
		lower: /[a-z]/.test(pass)
		upper: /[A-Z]/.test(pass)
		nonWords: /\W/.test(pass)
	variationCount = 0
	for check of variations
		variationCount += if variations[check] == true then 1 else 0
	score += (variationCount - 1) * 10
	return parseInt score








