import _clone from "ramda/es/clone"; import _curry from "ramda/es/curry"; import _find from "ramda/es/find"; import _findIndex from "ramda/es/findIndex"; import _isNil from "ramda/es/isNil"; import _length from "ramda/es/length"; import _match from "ramda/es/match"; import _memoizeWith from "ramda/es/memoizeWith"; import _replace from "ramda/es/replace"; import _split from "ramda/es/split"; import _test from "ramda/es/test"; import _toLower from "ramda/es/toLower"; import _type from "ramda/es/type"; import _whereEq from "ramda/es/whereEq"; #auto_require: _esramda
import {$, isNilOrEmpty} from "ramda-extras" #auto_require: esramda-extras
_ = (...xs) -> xs

import exchangeRates from './exchangeRates'
import {LexoRank} from "lexorank"

import {startOfWeek, parseISO} from 'date-fns'

import {countryByAlpha2} from './countries'


import 'dayjs/locale/en-gb'
import 'dayjs/locale/sv'
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
	[___, year, week] = _match(/(\d{4})[-w](\d+)/, yearWeek)
	firstDayOfYear = dayjs "#{year}-01-01"
	dayInWeek = firstDayOfYear.add week, 'weeks'
	mondayOfWeek = dayInWeek.startOf 'week'
	sundayOfWeek = dayInWeek.endOf 'week'
	return {start: mondayOfWeek.format(_YYYYMMDD), end: sundayOfWeek.format(_YYYYMMDD)}

MMMs = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

# Proxy for date related utils
export df =
	setLocale: (locale) -> dayjs.locale(locale)
	dayjs: dayjs
	# Mo = 0, Su = 6
	dayOfWeek: (date) ->
		dow = dayjs(date).day()
		if dow == 0 then 6
		else dow - 1
	format: _curry (format, _date) ->
		if _type(_date) == 'Number' && _date < 9000000000 then date = 1000 * _date # epoch seconds to milliseconds
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
	weekNum: (date) -> dayjs(date).week()
	weekStartEnd: (yearWeek) -> weekStartEnd yearWeek
	diff: _curry (early, late, unit) -> dayjs(late).diff(early, unit)
	get: _curry (unit, date) -> dayjs(date).get(unit)
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
		startOfWeek: _memoizeWith String, (date) -> # memoized so if testing for perf, second run will be faster
			newDate = new Date(date)
			day = newDate.getDay()
			daysToRemove = if day == 0 then 6 else day - 1 # sunday: 0, saturday: 6
			newDate.setDate(newDate.getDate() - daysToRemove)
			return newDate.toLocaleDateString('sv-SE')
		toMMM: (idx) -> MMMs[idx]



	# Tid mostly handles dates and we save quite a bit of complexity by defaulting to not care about time
	add: _curry (num, unit, date) -> dayjs(date).add(num, unit).format(_YYYYMMDD)
	subtract: _curry (num, unit, date) -> dayjs(date).subtract(num, unit).format(_YYYYMMDD)
	startOf: _curry (unit, date) -> dayjs(date).startOf(unit).format(_YYYYMMDD)
	endOf: _curry (unit, date) -> dayjs(date).endOf(unit).format(_YYYYMMDD)
	middleOf: _curry (earlier, later) ->
		earlierTime = (new Date earlier).getTime()
		laterTime = (new Date later).getTime()
		return dayjs(new Date (earlierTime + laterTime) / 2).format(_YYYYMMDD)

	t: # use df.t if you need to handle time and not only date
		add: _curry (num, unit, date) -> dayjs(date).add(num, unit).format()
		subtract: _curry (num, unit, date) -> dayjs(date).subtract(num, unit).format()
		startOf: _curry (unit, date) -> dayjs(date).startOf(unit).format()
		endOf: _curry (unit, date) -> dayjs(date).endOf(unit).format()

# eg. "Ornö brygga" -> "orno-brygga"
export toUrlFriendly = (s) ->
	$ s, _replace(/[A-Z]/, (x) -> _toLower x), _replace(/\s/, '-'), _replace(/ö/, 'o'), _replace(/[åä]/, 'a')

# Many libraries behave different based on NODE_ENV in optimization, logging etc.
# To keep environments as simialar as possible to prod we keep NODE_ENV set to production and use ENV instead.
# Local: NODE_ENV=dev ENV=dev, Test: NODE_ENV=production ENV=test, Prod: NODE_ENV=production ENV=prod
export isEnvProd = () -> process.env.NEXT_PUBLIC_ENV == 'prod'
export isEnvProdOrTest = () -> process.env.NEXT_PUBLIC_ENV == 'prod' || process.env.NEXT_PUBLIC_ENV == 'test'
export isEnvDev = () -> process.env.NEXT_PUBLIC_ENV == 'dev'


export capitalize = (s) -> s.charAt(0).toUpperCase() + s.slice(1)

export DEPRECATEDfromCurrency = (currency) ->
	countries = clm.getAllCountries()
	country = $ countries, _find _whereEq({currency})
	return fromCountryCode country?.alpha2

# Returns typical things for a country code, see example for 'CA' below
export DEPRECATEDfromCountryCode = (countryCode_) ->
	# https://github.com/srcagency/country-currencies SE -> SEK
	countryCode = countryCode_ || 'US' # fallback since we almost always want fallback
	three = clm.getAlpha3ByAlpha2 countryCode # CA -> CAN
	locale_ = clm.getLocaleByAlpha2(countryCode)
	locale = if locale_ then _replace(/_/g, '-', locale_)# CA -> en-CA
	name = clm.getCountryNameByAlpha2 countryCode # CA -> Canada
	currency = clm.getCurrencyByAlpha2 countryCode # CA -> CAD 
	return {three, locale, name, currency}

# 150099, 'SE' -> '1 500,99 kr'
# Note: amount is assumed in cents
# Opti: note that this is quite expensive
export DEPRECATEDformatCurrency = (amount, countryCode, removeZero = false, round = false, noSymbol = false) ->
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
export DEPRECATEDformatNumber2 = (amount, countryCode, removeZero = false, round = false) ->
	{currency, locale} = fromCountryCode countryCode || 'US'
	extra =
		if round || (removeZero && (amount % 100 == 0)) then {minimumFractionDigits: 0, maximumFractionDigits: 0}
		else {maximumFractionDigits: 2}

	# https://stackoverflow.com/q/44969852/416797
	amount.toLocaleString(locale, {style: undefined, currency: undefined, ...extra})




# Returns a formatting object for basic number and currency formatting given a country code.
# Intl.NumberFormat and toLocaleString are good but quite slow so 
# the idea is to call them to extract their good results to be used in cheaper formatting (see below).
# Note: probably only run this code at server and send result to client, don't include this in client bundle
# because clm is probably unnessesary big given that you most likely only need the formatting for one country.
#
# 'US' returns {thousandSeparator: ',', decimalPoint: '.', currencySymbol: '$', currencyBefore: true}
# 'SE' returns {thousandSeparator: ' ', decimalPoint: ',', currencySymbol: ' kr', currencyBefore: false}
export defaultFormattingFor = _memoizeWith String, (countryCode = 'US') ->
	# https://github.com/srcagency/country-currencies SE -> SEK
	# countryCode = _toUpper countryCode_
	# locale = countries.
	# locale = _replace '_', '-', clm.getLocaleByAlpha2(countryCode) # CA -> en-CA
	# currency = clm.getCurrencyByAlpha2 countryCode # CA -> CAD 
	{locale, currency} = countryByAlpha2[countryCode]

	nbs = ' ' # non-breaking space

	try 
		numStr = 1234.56.toLocaleString(locale, {style: undefined, currency: undefined})
		if numStr == '1,234.56' then thousandSeparator = ','; decimalPoint = '.'
		else if numStr == '1.234,56' then thousandSeparator = '.'; decimalPoint = ','
		else if numStr == '1\'234.56' then thousandSeparator = '\''; decimalPoint = '.'
		else if numStr == '1'+nbs+'234,56' then thousandSeparator = nbs; decimalPoint = ','
		else thousandSeparator = ','; decimalPoint = '.' # fallback to US standard

	catch err # fallback to US standard
		thousandSeparator = ',' 
		decimalPoint = '.'

	try
		opts = {style: 'currency', currency, minimumFractionDigits: 0, maximumFractionDigits: 0}
		curStr = new Intl.NumberFormat(locale, opts).format(1)
		if _test(/^1 /, curStr) then currencyBefore = false; currencySpace = true
		else if _test(/^1/, curStr) then currencyBefore = false; currencySpace = false
		else if _test(/1 $/, curStr) then currencyBefore = true; currencySpace = true
		else if _test(/1$/, curStr) then currencyBefore = true; currencySpace = false
		else currencySymbol = currency; currencyBefore = false; currencySpace = true;

		currencySymbol = $ curStr, _replace('1', ''), _replace(nbs, '')

	catch err # fallback to the letter currency and before
		currencySymbol = currency
		currencyBefore = false
		currencySpace = true

	try
		opts = {year: 'numeric', month: 'numeric', day: 'numeric'}
		curStr = new Intl.DateTimeFormat(locale, opts).format(new Date('2001-02-03'))
		if curStr == '02/03/2001' || curStr == '2/3/2001' then dateFormat = 'MM/DD/YYYY'
		else if curStr == '03/02/2001' || curStr == '3/2/2001' then dateFormat = 'DD/MM/YYYY'
		else if curStr == '2001-02-03' || curStr == '2001-2-3' then dateFormat = 'YYYY-MM-DD'
		else if curStr == '03.02.2001' || curStr == '3.2.2001' then dateFormat = 'DD.MM.YYYY'
		else if curStr == '2001.02.03' || curStr == '2001.2.3' then dateFormat = 'YYYY.MM.DD'
		else if curStr == '2001/02/03' || curStr == '2001/2/3' then dateFormat = 'YYYY/MM/DD'
		else dateFormat = 'YYYY-MM-DD'

	catch err # fallback to ISO standard
		dateFormat = 'YYYY-MM-DD'

	return {thousandSeparator, decimalPoint, currencySymbol, currencyBefore, currencySpace, dateFormat}


# export defaultUS = defaultFormattingFor 'US'
export defaultUS = {thousandSeparator: ",", decimalPoint: ".", "currencySymbol": "$", "currencyBefore": true, "currencySpace": false, "dateFormat": "MM/DD/YYYY"}


# This is a bit crazy, yes!
# But built-in formatting like
# 	- .toLocaleString
# 	- and new Intl.NumberFormat(...).format
# seem to be quite slow.
# Typical selectors in Time gets noticably slower (adding 4ms - 50ms) which is not fun.
# This is an experiment to make a good enough formatter that is decently fast.
#
# formatNumberFast 1234.56, {form: defaultSE, toFixed: 0, currency: null} returns '1 235'
# formatNumberFast 1234.56, {form: defaultUS, toFixed: 2, currency: 'symbol'} returns '$1,234.56'
# formatNumberFast 1234.56, {form: defaultSE, toFixed: 2, currency: 'symbol'} returns '1 234,56 kr'
# formatNumberFast 1234.00, {form: defaultSE, toFixed: 2, removeZero: true, currency: null} returns '1 234'
export formatNumberFast = (num, {form = defaultUS, toFixed = 2, removeZero = false, currency = null} = {}) ->
	s = ''
	numFixed = num.toFixed(toFixed)
	snum = Math.trunc(numFixed) + ''
	for i in [0...snum.length]
		if (snum.length - i) % 3 == 0 && i > 0 then s += form.thousandSeparator
		s += snum[i]

	if toFixed > 0 && !(numFixed % 1 == 0 && removeZero)
		s += form.decimalPoint + (numFixed % 1).toFixed(toFixed).substring(2)

	if currency == 'symbol'
		nbs = ' ' # non-breaking space
		currencySpaceOrEmpty = if form.currencySpace then nbs else ''
		if form.currencyBefore then s = form.currencySymbol + currencySpaceOrEmpty + s
		else s += currencySpaceOrEmpty + form.currencySymbol
	else if currency == 'separate' || currency == 'separateTrim'
		nbs = ' ' # non-breaking space
		ret = []
		before = if form.currencyBefore then form.currencySymbol else null
		sWithSpace = s
		if form.currencySpace && currency != 'separateTrim'
			if form.currencyBefore then sWithSpace = nbs + s
			else sWithSpace = s + nbs
		after = if !form.currencyBefore then form.currencySymbol else null
		return [before, sWithSpace, after]

	return s


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
	activeIndex = _findIndex _whereEq({id: activeId}), list
	overIndex = _findIndex _whereEq({id: overId}), list
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

# returns a "nice looking" number given a number
# 8512 -> 8500
# 851.123 -> 850
export roundToNiceNumber = (n) ->
	len = _length Math.round(n) + ''
	divider = Math.pow 10, len - 2
	return Math.round(n / divider) * divider


export sleep = (ms) -> new Promise (resolve) -> setTimeout(resolve, ms)

# Takes a start and end date and returns:
# [identified period,    formatted period,     period id]
# eg. start='2021-05-03', end='2021-05-09' -> ['week', 'May 3 - 9', 'w2021-05-03']
# Discussion:
# + Looks nice in the url
# + More performant than in a loop in a selector having to calculate "#{startOf 'week', date}-#{endOf 'week', date}"
# - Adds complexity
export formatPeriod = (start, end, {now = Date.now(), long = false, locale = 'en'} = {}) ->
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
			return ['month', "#{df.format(fM, start)}#{extra}", "m#{start}"]

	if df.isSame df.startOf('week', start), start, 'day'
		if df.isSame df.endOf('week', start), end, 'day'
			if locale == 'sv'
				weekText = if long then 'Vecka ' else 'V'
				return ['week', "#{weekText}#{df.weekNum start}#{yearEnd}", "w#{start}"]
			else
				startMMM = df.format(fM, start)
				endMMM = df.format(fM, end)
				extra = if startMMM == endMMM then '' else endMMM + ' '
				return ['week', "#{startMMM} #{df.format('D', start)} - #{extra}#{df.format('D', end)}#{yearEnd}", "w#{start}"]

	if df.isSame df.startOf('quarter', start), start, 'day'
		if df.isSame df.endOf('quarter', start), end, 'day'
			return ['quarter', "Q#{df.format('Q', start)} #{df.format('YYYY', start)}", "q#{start}"]

	if df.isSame df.startOf('year', start), start, 'day'
		if df.isSame df.endOf('year', end), end, 'day'
			return ['year', "#{df.format('YYYY', start)}", "y#{start}"]

	customId = "#{df.format _YYYYMMDD, start}-#{df.format _YYYYMMDD, end}"

	if df.isSame start, end, 'day'
		return ['custom', "#{df.format(fM, start)} #{df.format('D', start)}#{yearEnd}", customId]

	if df.isSame start, end, 'month'
		return ['custom', "#{df.format(fM, start)} #{df.format('D', start)} - #{df.format('D', end)}#{yearEnd}", customId]
	else
		return ['custom', "#{df.format(fM, start)} #{df.format('D', start)}#{yearStart} - 
		#{df.format(fM, end)} #{df.format('D', end)}#{yearEnd}", customId]


# Expands a periodId to start and end dates
# eg. m2021-01-01 -> ['month', '2021-01-01', '2021-01-31']
REcustomPeriod = /^\d{4}-\d{2}-\d{2}-\d{4}-\d{2}-\d{2}$/
export expandPeriodId = (periodId, options) ->
	periodShort = periodId[0]
	periodFull = null
	if periodShort == 'w' then periodFull = 'week'
	else if periodShort == 'm' then periodFull = 'month'
	else if periodShort == 'q' then periodFull = 'quarter'
	else if periodShort == 'y' then periodFull = 'year'
	else if _test REcustomPeriod, periodId
		start = periodId.substring 0, 10
		end = periodId.substring 11, 21
		return ['custom', start, end]
	else throw new Error 'Invalid periodId'

	start = periodId.substring 1
	end = df.endOf(periodFull, start)
	return [periodFull, start, end]

# TIME e.g. 0:10, 2:50 ----------------------------------------------------------------------------
export toHMM = (n) ->
	if _isNil n then return null
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
	if _test(/:/, s)
		[h, mm] = _split ':', s
		if isNilOrEmpty mm then return _nullIfNaN parseInt(h)
		else if isNilOrEmpty h then return _nullIfNaN parseFloat(mm) / 60
		return parseInt(h) + parseFloat(mm) / 60
	else if _test(/,/, s) then return _nullIfNaN parseFloat _replace ',', '.', s
	else return _nullIfNaN parseFloat s

# Returns a new array where element on idx1 is swaped with element on idx2.
# Note: the elements in the new array are not clones so if you mutate one it will mutate in the original
# array too (the object pointed to by the original array and new array are the same).
export swap = _curry (idx1, idx2, xs) ->
	# arr = []
	# for x in xs then arr.push x
	arr = _clone xs
	temp = arr[idx1]
	arr[idx1] = arr[idx2]
	arr[idx2] = temp
	return arr

# We sometimes optimistically create some data client side with a temporary id that then later is saved in db
# and is given a permanent id. When the swap of the temporary id to the permanent id happens in the client
# side cache it can cause rendering issues if the id is used as a react key for a component since the
# component is then removed and another component is rendered in it's place and all state is lost.
# The simple solution is that we keep the tempId on the object in the cache and use that if present for
# components that otherwise would loose it's state in such a cache swap.
export safeId = ({id, tempId}) -> if !_isNil tempId then tempId else id

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


# Simple normalization function to use with results from the database
export norm = (list) ->
	ret = {}
	for o in list
		ret[o.id] = o
	return ret







