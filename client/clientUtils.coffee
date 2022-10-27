fromPairs = require('ramda/src/fromPairs'); init = require('ramda/src/init'); isEmpty = require('ramda/src/isEmpty'); isNil = require('ramda/src/isNil'); last = require('ramda/src/last'); length = require('ramda/src/length'); map = require('ramda/src/map'); match = require('ramda/src/match'); path = require('ramda/src/path'); pickBy = require('ramda/src/pickBy'); replace = require('ramda/src/replace'); split = require('ramda/src/split'); test = require('ramda/src/test'); type = require('ramda/src/type'); #auto_require: srcramda
import {$, isNotNil, toStr} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

import React from 'react'

# Shared utils
# TODO: figure out way to add all from sharedUtils


########## UTILS #############################################################################################
export capitalize = (s) -> s.charAt(0).toUpperCase() + s.slice(1)

export equalsAt = (pathStr, o1, o2) ->
	spaths = split ',', pathStr
	for spath in spaths
		p = split '.', spath
		if last(p) == '*'
			p_ = init p
			o1p = path p_, o1
			o2p = path p_, o2
			console.log o1p, o2p
			for k,v of o1p
				if o2p[k] != v then return false
		else
			if path(p, o1) != path(p, o2) then return false

	return true

export emptyIfNil = (x) -> if isNil x then '' else x

export cutTextAt = (n, s) ->
	if isNil s then ''
	else if length(s) > n then s.substr(0, n) + '...'
	else return s

export toHMM = (n) ->
	if isNil n then return null
	h = toH n
	mm = toMM n
	return "#{h}:#{mm}"

export toH = (n) -> Math.trunc n

export toMM = (n) ->
	decimalPart = n % 1
	m = Math.round decimalPart * 60
	if m < 10 then '0' + m else m

export onlyInteger = (n) -> Math.trunc n
export onlyDecimal = (n) -> $ n.toFixed(2), toStr, replace(/.*\./, '.')

export flattenEntity = (o) ->
	res = {}
	for k, v of o
		switch type v
			when 'Null', 'String', 'Number', 'Boolean' then res[k] = v
			when 'Object' then res["#{k}Id"] = v.id
			else throw new Error 'NYI'
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
	return [offsetTop, offsetLeft]

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
	if isNil el then return {top: 0, right: 0, bottom: 0, left: 0}
	rect = el.getBoundingClientRect()

	return 
		top: rect.top
		right: (window.innerWidth || document.documentElement.clientWidth) - rect.right
		bottom: (window.innerHeight || document.documentElement.clientHeight) - rect.bottom
		left: rect.left


# Optimistically parses to Number or Boolean if needed
autoParse = (val) ->
	if !isNaN(val) then Number(val)
	else if val == 'true' then true
	else if val == 'false' then false
	else if test /^\[.*\]$/, val # arrays eg. "[1, 2]" --> [1, 2]
		if val == '[]' then []
		else $ val[1...val.length-1], split(','), map autoParse
	else val

# Parses url string to object
# eg. '/p/q/r?a=1&b=2' -> {path0: 'p', path1: 'q', path2: 'r', a: 1, b: 2}
export fromUrl = (url) ->
	[pathStr, queryStr] = $ url, replace(/^\//, ''), split '?'
	[path0, path1, path2, path3, path4] = if isEmpty pathStr then [] else split '/', pathStr
	qs = $ queryStr || '', split('&'), map(split('=')), fromPairs

	return $ {path0, path1, path2, path3, path4, ...qs}, pickBy(isNotNil), map(autoParse)


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








