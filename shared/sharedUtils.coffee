clone = require('ramda/src/clone'); curry = require('ramda/src/curry'); isNil = require('ramda/src/isNil'); length = require('ramda/src/length'); map = require('ramda/src/map'); match = require('ramda/src/match'); replace = require('ramda/src/replace'); split = require('ramda/src/split'); test = require('ramda/src/test'); toLower = require('ramda/src/toLower'); type = require('ramda/src/type'); #auto_require: srcramda
import {$, isNilOrEmpty} from "ramda-extras" #auto_require: esramda-extras
import clm from "country-locale-map"
import exchangeRates from './exchangeRates'
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs


require 'dayjs/locale/en-gb'
dayjs = require 'dayjs'
dayjs.locale('en-gb') # en-gb starts week on monday, en does not
quarterOfYear = require 'dayjs/plugin/quarterOfYear'
dayjs.extend quarterOfYear
weekOfYear = require 'dayjs/plugin/weekOfYear'
dayjs.extend weekOfYear
# weekday = require 'dayjs/plugin/weekday'
# dayjs.extend weekday
customParseFormat = require 'dayjs/plugin/customParseFormat'
dayjs.extend customParseFormat

_YYYYMMDD = 'YYYY-MM-DD'

# Proxy for date related utils
export df =
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

	# Tid mostly handles dates and we save quite a bit of complexity by defaulting to not care about time
	add: curry (num, unit, date) -> dayjs(date).add(num, unit).format(_YYYYMMDD)
	subtract: curry (num, unit, date) -> dayjs(date).subtract(num, unit).format(_YYYYMMDD)
	startOf: curry (unit, date) -> dayjs(date).startOf(unit).format(_YYYYMMDD)
	endOf: curry (unit, date) -> dayjs(date).endOf(unit).format(_YYYYMMDD)

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
export isEnvProd = () -> process.env.ENV == 'prod'
export isEnvProdOrTest = () -> process.env.ENV == 'prod' || process.env.ENV == 'test'
export isEnvDev = () -> process.env.ENV == 'dev'

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

export exchangeRatesFromEuro = exchangeRates

# export formatNumber2 = (n, countryCode, )

# 23.1234 -> 23.12
# 23.00, true -> 23
# 23.123456, true, 5 -> 23.12346
export formatNumber = (n, removeZero = false, decimals = 2) ->
	if removeZero && n % 1 == 0 then return '' + n
	return '' + n.toFixed decimals

# 8512 -> 8500
# 851.123 -> 850
export roundTwoDigits = (n) ->
	len = length Math.round(n) + ''
	divider = Math.pow 10, len - 2
	return Math.round(n / divider) * divider

export sleep = (ms) -> new Promise (resolve) -> setTimeout(resolve, ms)

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
