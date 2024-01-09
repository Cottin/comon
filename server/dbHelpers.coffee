import _hasIn from "ramda/es/hasIn"; import _isNil from "ramda/es/isNil"; import _type from "ramda/es/type"; #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras




# Makes a short string for nicer logging to indicate the size of a result
export shortResult = (res) ->
	if res instanceof Array
		if res.length == 0 then return "[]"
		else if res.length == 1 then return "[{..}]"
		else if res.length == 2 then return "[{..}, {..}]"
		else return "[{..}, {..}, ...]"


# Takes the args from a call to a tagged template and prepares a sql string with $.
# e.g. prepareWithParams [["select * from user where id = ", ""], 1]
# 			returns 'select * from user where id = $1', [1]
# Original: https://github.com/vercel/storage/blob/main/packages/postgres/src/sql-template.ts
export prepareWithParams = (strings, ...values) ->
	if !isTemplateStringsArray(strings) || !Array.isArray(values)
		throw new Error "Looks like you tried calling sql as a function. Make sure to use it as tagged template."

	ret = if _isNil(strings[0]) then '' else strings[0]

	for str, i in strings
		if i == 0 then continue
		ret += "$#{i}#{if _isNil(str) then '' else str}"

	return [ret, values]

isTemplateStringsArray = (strings) ->
	return Array.isArray(strings) && _hasIn('raw', strings) && Array.isArray(strings.raw)


# Turns the arguments of a tagged template literal into the full string.
# DANGER! Will allow sql-injections. Only use this for logging and simple copy paste to db client
# in dev environments.
export prepareDangerous = (strings,  ...values) ->
	str = ''
	for part, i in strings
		str += part
		if i < values.length then str += paramToStr values[i]
	return str

paramToStr = (val) ->
	switch _type val
		when 'String' then "'" + val + "'"
		when 'Number' then val
		else val

