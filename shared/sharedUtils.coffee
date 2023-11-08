import clone from "ramda/es/clone"; import curry from "ramda/es/curry"; import findIndex from "ramda/es/findIndex"; import isNil from "ramda/es/isNil"; import length from "ramda/es/length"; import map from "ramda/es/map"; import match from "ramda/es/match"; import max from "ramda/es/max"; import memoizeWith from "ramda/es/memoizeWith"; import min from "ramda/es/min"; import replace from "ramda/es/replace"; import split from "ramda/es/split"; import test from "ramda/es/test"; import toLower from "ramda/es/toLower"; import type from "ramda/es/type"; import whereEq from "ramda/es/whereEq"; #auto_require: esramda
import {$, isNilOrEmpty} from "ramda-extras" #auto_require: esramda-extras
_ = (...xs) -> xs

import clm from "country-locale-map"
import exchangeRates from './exchangeRates'
import {LexoRank} from "lexorank"

import {startOfWeek, parseISO} from 'date-fns'


import 'dayjs/locale/en-gb'
import dayjs from 'dayjs'
dayjs.locale('en-gb') # en-gb starts week on monday, en does not
import quarterOfYear from 'dayjs/plugin/quarterOfYear'
dayjs.extend quarterOfYear
import weekOfYear from 'dayjs/plugin/weekOfYear'
dayjs.extend weekOfYear
# import utc from 'dayjs/plugin/utc'
# dayjs.extend utc

# import timezone from 'dayjs/plugin/timezone'
# dayjs.extend timezone
# dayjs.tz.setDefault "America/New_York"

# weekday = require 'dayjs/plugin/weekday'
# dayjs.extend weekday
import customParseFormat from 'dayjs/plugin/customParseFormat'
dayjs.extend customParseFormat

_YYYYMMDD = 'YYYY-MM-DD'

# dayjs/plugin/weekOfYear is slow and causes perf problems if used on a long list. Here is a fast alternative.
# TODO: Funkar det här verkligen på 53 veckors år? Tror inte det
# https://gist.github.com/IamSilviu/5899269
cheapWeek = (date_) ->
	date = new Date date_
	firstDayOfYear = new Date date.getFullYear(), 0, 1
	pastDaysOfYear = (date - firstDayOfYear) / 86400000
	return -1 + Math.ceil (pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7

weekStartEnd = (yearWeek) ->
	[___, year, week] = match(/(\d{4})[-w](\d+)/, yearWeek)
	firstDayOfYear = dayjs "#{year}-01-01"
	dayInWeek = firstDayOfYear.add week, 'weeks'
	mondayOfWeek = dayInWeek.startOf 'week'
	sundayOfWeek = dayInWeek.endOf 'week'
	return {start: mondayOfWeek.format(_YYYYMMDD), end: sundayOfWeek.format(_YYYYMMDD)}


# Proxy for date related utils
export df =
	dayjs: dayjs
	# Mo = 0, Su = 6
	dayOfWeek: (date) ->
		dow = dayjs(date).day()
		if dow == 0 then 6
		else dow - 1
	format: curry (format, _date) ->
		if type(_date) == 'Number' && _date < 9000000000 then date = 1000 * _date # epoch seconds to milliseconds
		else date = _date

		if format == 'W' then dayjs(date).week() # shorthand for simple format W and Q
		else if format == 'Q' then dayjs(date).quarter()
		else if format == 'Dth'
			dateS = dayjs(date).format 'D'
			dateI = parseInt dateS
			ordinal = switch dateI
				when 1 then 'st'
				when 2 then 'nd'
				when 3 then 'rd'
				else 'th'
			return "#{dateS}#{ordinal}"
		else dayjs(date).format(format)
	sow: (date) -> startOfWeek parseISO date
	dayjs: (date) -> dayjs(date) # supplied for performance critical parts
	cheapWeek: (date) -> cheapWeek date
	weekStartEnd: (yearWeek) -> weekStartEnd yearWeek
	diff: curry (early, late, unit) -> dayjs(late).diff(early, unit)
	get: curry (unit, date) -> dayjs(date).get(unit)
	isAfter: (date1, date2, unit = undefined) -> dayjs(date1).isAfter(date2, unit)
	isAfterOrSame: (date1, date2, unit = undefined) ->
		dayjs(date1).isAfter(date2, unit) || dayjs(date1).isSame(date2, unit)
	isBefore: (date1, date2, unit = undefined) -> dayjs(date1).isBefore(date2, unit)
	isBeforeOrSame: (date1, date2, unit = undefined) ->
		dayjs(date1).isBefore(date2, unit) || dayjs(date1).isSame(date2, unit)
	isBetweenOrSame: (date, date1, date2, unit = undefined) ->
		dayjs(date).isAfter(date1, unit) && dayjs(date).isBefore(date2, unit)
	isSame: (date1, date2, unit = undefined) -> dayjs(date1).isSame(date2, unit)
	isValid: (date) -> dayjs(date, 'YYYY-MM-DD', true).isValid()
	yyyymmdd: (date) -> dayjs(date).format 'YYYY-MM-DD'
	now: () -> dayjs().format 'YYYY-MM-DD'
	isWeekend: (date) -> dayjs(date).day() == 0 || dayjs(date).day() == 6
	daysInMonth: (date) -> dayjs(date).daysInMonth()

	opti: # experiment to do a couple of optimized alternatives to use in hot paths since dayjs is quite slow
		addDays: (days, date) ->
			newDate = new Date(date)
			newDate.setDate newDate.getDate() + days
			return newDate.toLocaleDateString('sv-SE')
		startOfWeek: memoizeWith String, (date) -> # memoized so if testing for perf, second run will be faster
			newDate = new Date(date)
			day = newDate.getDay()
			daysToRemove = if day == 0 then 6 else day - 1 # sunday: 0, saturday: 6
			newDate.setDate(newDate.getDate() - daysToRemove)
			return newDate.toLocaleDateString('sv-SE')



	# Tid mostly handles dates and we save quite a bit of complexity by defaulting to not care about time
	add: curry (num, unit, date) -> dayjs(date).add(num, unit).format(_YYYYMMDD)
	subtract: curry (num, unit, date) -> dayjs(date).subtract(num, unit).format(_YYYYMMDD)
	startOf: curry (unit, date) -> dayjs(date).startOf(unit).format(_YYYYMMDD)
	endOf: curry (unit, date) -> dayjs(date).endOf(unit).format(_YYYYMMDD)
	middleOf: curry (earlier, later) ->
		earlierTime = (new Date earlier).getTime()
		laterTime = (new Date later).getTime()
		return dayjs(new Date (earlierTime + laterTime) / 2).format(_YYYYMMDD)

	t: # use df.t if you need to handle time and not only date
		add: curry (num, unit, date) -> dayjs(date).add(num, unit).format()
		subtract: curry (num, unit, date) -> dayjs(date).subtract(num, unit).format()
		startOf: curry (unit, date) -> dayjs(date).startOf(unit).format()
		endOf: curry (unit, date) -> dayjs(date).endOf(unit).format()

# eg. "Ornö brygga" -> "orno-brygga"
export toUrlFriendly = (s) ->
	$ s, replace(/[A-Z]/, (x) -> toLower x), replace(/\s/, '-'), replace(/ö/, 'o'), replace(/[åä]/, 'a')

# Many libraries behave different based on NODE_ENV in optimization, logging etc.
# To keep environments as simialar as possible to prod we keep NODE_ENV set to production and use ENV instead.
# Local: NODE_ENV=dev ENV=dev, Test: NODE_ENV=production ENV=test, Prod: NODE_ENV=production ENV=prod
export isEnvProd = () -> process.env.NEXT_PUBLIC_ENV == 'prod'
export isEnvProdOrTest = () -> process.env.NEXT_PUBLIC_ENV == 'prod' || process.env.NEXT_PUBLIC_ENV == 'test'
export isEnvDev = () -> process.env.NEXT_PUBLIC_ENV == 'dev'

# Returns typical things for a country code, see example for 'CA' below
export fromCountryCode = (countryCode_) ->
	# https://github.com/srcagency/country-currencies SE -> SEK
	countryCode = countryCode_ || 'US' # fallback since we almost always want fallback
	three = clm.getAlpha3ByAlpha2 countryCode # CA -> CAN
	locale_ = clm.getLocaleByAlpha2(countryCode)
	locale = if locale_ then replace '_', '-', locale_# CA -> en-CA
	name = clm.getCountryNameByAlpha2 countryCode # CA -> Canada
	currency = clm.getCurrencyByAlpha2 countryCode # CA -> CAD 
	return {three, locale, name, currency}

# 150099, 'SE' -> '1 500,99 kr'
# Note: amount is assumed in cents
export formatCurrency = (amount, countryCode, removeZero = false, round = false, noSymbol = false) ->
	{currency, locale} = fromCountryCode countryCode || 'US'
	extra =
		if round || (removeZero && (amount % 100 == 0)) then {minimumFractionDigits: 0, maximumFractionDigits: 0}
		else {}
	opts = {style: 'currency', currency, ...extra}

	# https://stackoverflow.com/q/44969852/416797
	if noSymbol then (amount / 100).toLocaleString(locale, {...opts, style: undefined, currency: undefined})
	else new Intl.NumberFormat(locale, opts).format(amount / 100)

# 150099, 'SE' -> '1 500,99 kr'
# Note: amount is assumed in cents
export formatNumber2 = (amount, countryCode, removeZero = false, round = false) ->
	{currency, locale} = fromCountryCode countryCode || 'US'
	extra =
		if round || (removeZero && (amount % 100 == 0)) then {minimumFractionDigits: 0, maximumFractionDigits: 0}
		else {maximumFractionDigits: 2}

	# https://stackoverflow.com/q/44969852/416797
	amount.toLocaleString(locale, {style: undefined, currency: undefined, ...extra})

export exchangeRatesFromEuro = exchangeRates

export byId = (xs) ->
	ret = {}
	for x in xs then ret[x.id] = x
	return ret

export getNewRank = (rankBefore, rankAfter) ->
	if rankBefore && rankAfter then LexoRank.parse(rankBefore).between(LexoRank.parse(rankAfter)).toString()
	else if rankBefore then LexoRank.parse(rankBefore).genNext().toString()
	else if rankAfter then LexoRank.parse(rankAfter).genPrev().toString()
	else LexoRank.middle().toString()

# returns new rank based on activeId (dragged item), overId (item dragged over) and the sorted list
# 1, 4, [{id: 4, rank: '0|h1'}, {id: 1, rank: '0|h3'}, ...]
export getNewRankFromList = (activeId, overId, list) ->
	activeIndex = findIndex whereEq({id: activeId}), list
	overIndex = findIndex whereEq({id: overId}), list
	getRank = (index) -> list[index].rank

	if overIndex == 0 then afterRank = getRank overIndex
	else if overIndex == list.length - 1 then beforeRank = getRank overIndex
	else if activeIndex > overIndex
		beforeRank = getRank overIndex - 1
		afterRank = getRank overIndex
	else
		beforeRank = getRank overIndex
		afterRank = getRank overIndex + 1

	return getNewRank beforeRank, afterRank

# 23.1234 -> 23.12
# 23.00, true -> 23
# 23.123456, true, 5 -> 23.12346
export formatNumber = (n, removeZero = false, decimals = 2) ->
	if removeZero && n % 1 == 0 then return '' + n
	return '' + n.toFixed decimals

# 123132 -> 123 k
export formatBigNumber = (n) ->
	if n > 1000 then return Math.round(n / 1000) + ' k'
	else return Math.round n

# 8512 -> 8500
# 851.123 -> 850
export roundTwoDigits = (n) ->
	len = length Math.round(n) + ''
	divider = Math.pow 10, len - 2
	return Math.round(n / divider) * divider

export sleep = (ms) -> new Promise (resolve) -> setTimeout(resolve, ms)

export formatPeriod = (start, end, {now = Date.now(), long = false} = {}) ->
	if df.isBefore end, start then return [null, 'Invalid period']
	if !df.isValid start then return [null, 'Invalid start date']
	if !df.isValid end then return [null, 'Invalid end date']

	yearEnd = if df.isSame end, now, 'year' then '' else " #{df.format 'YYYY', end}"
	yearStart = if df.isSame start, now, 'year' then '' else " #{df.format 'YYYY', start}"
	if yearStart != '' then yearEnd = " #{df.format 'YYYY', end}"
	fM = if long then 'MMMM' else 'MMM'

	if df.isSame df.startOf('month', start), start, 'day'
		if df.isSame df.endOf('month', start), end, 'day'
			extra = if df.isSame end, now, 'year' then '' else ' ' + df.format('YYYY', start)
			return ['month', "#{df.format(fM, start)}#{extra}"]

	if df.isSame df.startOf('week', start), start, 'day'
		if df.isSame df.endOf('week', start), end, 'day'
			startMMM = df.format(fM, start)
			endMMM = df.format(fM, end)
			extra = if startMMM == endMMM then '' else endMMM + ' '
			return ['week', "#{startMMM} #{df.format('D', start)} - #{extra}#{df.format('D', end)}#{yearEnd}"]

	if df.isSame df.startOf('quarter', start), start, 'day'
		if df.isSame df.endOf('quarter', start), end, 'day'
			return ['quarter', "Q#{df.format('Q', start)} #{df.format('YYYY', start)}"]

	if df.isSame df.startOf('year', start), start, 'day'
		if df.isSame df.endOf('year', end), end, 'day'
			return ['year', "#{df.format('YYYY', start)}"]

	if df.isSame start, end, 'day'
		return ['custom', "#{df.format(fM, start)} #{df.format('D', start)}#{yearEnd}"]

	if df.isSame start, end, 'month'
		return ['custom', "#{df.format(fM, start)} #{df.format('D', start)} - #{df.format('D', end)}#{yearEnd}"]
	else
		return ['custom', "#{df.format(fM, start)} #{df.format('D', start)}#{yearStart} - 
		#{df.format(fM, end)} #{df.format('D', end)}#{yearEnd}"]

# TIME e.g. 0:10, 2:50 ----------------------------------------------------------------------------
export toHMM = (n) ->
	if isNil n then return null
	h = toH n
	mm = toMM n
	return "#{h}"+':'+"#{mm}"

export toH = (n) -> Math.trunc n

export toMM = (n) ->
	decimalPart = n % 1
	m = Math.round decimalPart * 60
	if m < 10 then '0' + m else m

_nullIfNaN = (x) -> if isNaN x then null else x

export fromHHMMorDec = (s) ->
	if test(/:/, s)
		[h, mm] = split ':', s
		if isNilOrEmpty mm then return _nullIfNaN parseInt(h)
		else if isNilOrEmpty h then return _nullIfNaN parseFloat(mm) / 60
		return parseInt(h) + parseFloat(mm) / 60
	else if test(/,/, s) then return _nullIfNaN parseFloat replace ',', '.', s
	else return _nullIfNaN parseFloat s

# Returns a new array where element on idx1 is swaped with element on idx2.
# Note: the elements in the new array are not clones so if you mutate one it will mutate in the original
# array too (the object pointed to by the original array and new array are the same).
export swap = curry (idx1, idx2, xs) ->
	# arr = []
	# for x in xs then arr.push x
	arr = clone xs
	temp = arr[idx1]
	arr[idx1] = arr[idx2]
	arr[idx2] = temp
	return arr

export trycatch = (promise) ->
	try
		res = await promise
		return res
	catch err
		return undefined

# Given a y-value, returns 3 y-values to segment in a "nice" way, eg. 25, 50 75.
# The definition of a "nice" way is not obvious. Now going for 0, 25, 50, 75 break-points.
# Tried google and ChatGPT to find a common way of doing this but without success. The current approach is
# probably not the best but good enough for now.
export niceLines = (yValue) ->
	by3unscaled = (yValue * 1.2) / 3
	scale = 10 ** ((Math.floor(by3unscaled) + '').length - 1)
	by3 = by3unscaled / scale
	factor = 1

	if by3 % 1 == 0 then factor = by3
	else if by3 < 1 then throw new Error 'nyi'
	else if by3 < 1.5 then factor = 1.0
	else if by3 < 2.5 then factor = 1.5
	else if by3 < 3.0 then factor = 2.5
	else if by3 < 5.0 then factor = 2.5
	else if by3 < 6.0 then factor = 5.0
	else if by3 < 7.0 then factor = 5.0
	else if by3 < 8.0 then factor = 7.5
	else if by3 < 9.0 then factor = 7.5
	else if by3 < 10.0 then factor = 7.5
	else throw new Error 'nyi'

	return [factor * scale, factor * scale * 2, factor * scale * 3]

export calcNicePeriod = (min, max) ->
	if min > max then throw new Error 'min bigger than max'
	[minYear, minMonth] = [min.substring(0, 4), min.substring(5, 7)]
	[maxYear, maxMonth] = [max.substring(0, 4), max.substring(5, 7)]

	if minYear == maxYear
		if minMonth == maxMonth then return "m#{minYear}-#{minMonth}-01"
		else return "y#{minYear}-01-01"

	# Note that there are room for improvements here
	return 'total'












