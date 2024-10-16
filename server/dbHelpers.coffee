import _addIndex from "ramda/es/addIndex"; import _clone from "ramda/es/clone"; import _hasIn from "ramda/es/hasIn"; import _includes from "ramda/es/includes"; import _isNil from "ramda/es/isNil"; import _keys from "ramda/es/keys"; import _map from "ramda/es/map"; import _mapObjIndexed from "ramda/es/mapObjIndexed"; import _split from "ramda/es/split"; import _type from "ramda/es/type"; #auto_require: _esramda
import {$} from "ramda-extras" #auto_require: esramda-extras




# Makes a short string for nicer logging to indicate the size of a result
export shortResult = (res) ->
	if res instanceof Array
		if res.length == 0 then return "[]"
		else return "[#{res.length} item#{res.length > 1 && 's' || ''}]"


# Takes the args from a call to a tagged template and prepares a sql string with $.
# e.g. prepareWithParams [["select * from user where id = ", ""], 1]
# 			returns 'select * from user where id = $1', [1]
# Original: https://github.com/vercel/storage/blob/main/packages/postgres/src/sql-template.ts
# Special feature: If a template argument is a Set with one element which is an object it will be interspersed
# with the sql string like so "key1 = $X, key2 = $Y", [..., value1, value2, ...] similar to update statements.
# e.g. prepareWithParams"update table set #{new Set([{name: 'bob', age: 5}])} where id = #{9}"
#				returns 'update table set name = $1, age = $2 where id = $3', ['bob', 5, 9]
# Note that the values of the Set element will be parameterized and subject to the same sql injection
# sanitization in the sql library you use exactly like how other params will. However, the keys of the Set 
# element will not!! So make sure to valiate those keys agains fields in an entity model or similar.
# The use of Set is intentional since Set's cannot be passed in json so user input sent over json can never
# be manipulated to become a Set.
# Note: also returns stringsToUse if you want to use the Set functionality but need to pass the results into
# a function that expects to be called as a tagged template.
export prepareWithParams = (strings, ...values) ->
	return prepareWithParamsRaw 0, strings, values...

# Same as prepareWithParams but you can add to the previous result
# e.g. prepareWithParamsRecursive(["select * from user where id = ", ""], 1).add([" and active = ", ""], true)
#				returns 'select * from user where id = $1 and active = $2', [1, true]
export prepareWithParamsRecursive = (strings, ...values) ->
	firstResult = prepareWithParamsRaw 0, strings, values...

	firstResult.add = (strings2, ...values) ->
		additionalResult = prepareWithParamsRaw firstResult[1].length, strings2, values...
		firstResult[0] += additionalResult[0]
		firstResult[1].push additionalResult[1]...

		# we need to merge the last string of previous result with first string of next result
		firstResult[2][firstResult[2].length - 1] += additionalResult[2][0]

		firstResult[2].push additionalResult[2].slice(1)...
		return this

	return firstResult


prepareWithParamsRaw = (offset, strings, ...values) ->
	if !isTemplateStringsArray(strings) || !Array.isArray(values)
		throw new Error "Looks like you tried calling sql as a function. Make sure to use it as tagged template."

	stringsToUse = []
	valuesToUse = []

	lastStr = ''
	for val, i in values
		if _type(val) == 'Set'
			if val.size != 2 then throw new Error 'Invalid size of Set'
			[data, fn] = Array.from val
			if _type(data) != 'Object' then throw new Error 'Invalid type of 0 in Set'
			if _type(fn) != 'Function' then throw new Error 'Invalid type of 1 in Set'
			PARAM = '___PARAM___'
			NOTSET = '___NOT_SET___'
			lastStr = lastStr + strings[i]
			tempValue = NOTSET
			useParam = (value) ->
				tempValue = value
				return PARAM
			count = 0
			$ data, _mapObjIndexed (v, k) ->
				res = fn k, v, useParam
				if tempValue == NOTSET
					lastStr += res
				else
					if (res.match(new RegExp(PARAM, 'g')) || []).length > 1
						throw new Error 'Not allowed to call useParam more than once'
					[before, after] = _split(PARAM, res)
					stringsToUse.push lastStr + before
					valuesToUse.push tempValue
					tempValue = NOTSET
					lastStr = after

				if count++ < _keys(data).length-1 then lastStr += ', '

		else
			stringsToUse.push lastStr + strings[i]
			valuesToUse.push values[i]

	stringsToUse.push strings[strings.length - 1]

	ret = ''
	for val, i in valuesToUse
		ret += "#{stringsToUse[i]}$#{i+offset+1}"

	ret += stringsToUse[stringsToUse.length - 1]

	return [ret, valuesToUse, stringsToUse]


isTemplateStringsArray = (strings) ->
	return Array.isArray(strings) && _hasIn('raw', strings) && Array.isArray(strings.raw)




# Takes the args from a call to a tagged template and prepares a sql string with $.
# e.g. prepareWithParams [["select * from user where id = ", ""], 1]
# 			returns 'select * from user where id = $1', [1]
# Original: https://github.com/vercel/storage/blob/main/packages/postgres/src/sql-template.ts
# Special feature: If a template argument is a Set with one element which is an object it will be interspersed
# with the sql string like so "key1 = $X, key2 = $Y", [..., value1, value2, ...] similar to update statements.
# e.g. prepareWithParams"update table set #{new Set([{name: 'bob', age: 5}])} where id = #{9}"
#				returns 'update table set name = $1, age = $2 where id = $3', ['bob', 5, 9]
# Note that the values of the Set element will be parameterized and subject to the same sql injection
# sanitization in the sql library you use exactly like how other params will. However, the keys of the Set 
# element will not!! So make sure to valiate those keys agains fields in an entity model or similar.
# The use of Set is intentional since Set's cannot be passed in json so user input sent over json can never
# be manipulated to become a Set.
# Note: also returns stringsToUse if you want to use the Set functionality but need to pass the results into
# a function that expects to be called as a tagged template.
export prepareWithParamsOLD = (strings, ...values) ->
	if !isTemplateStringsArray(strings) || !Array.isArray(values)
		throw new Error "Looks like you tried calling sql as a function. Make sure to use it as tagged template."

	stringsToUse = _clone strings
	valuesToUse = []

	for val in values
		if _type(val) == 'Set'
			if val.size != 2 then throw new Error 'Invalid size of Set'
			[data, fn] = Array.from val
			if _includes _type(data), ['Object', 'Array'] then throw new Error 'Invalid first element of Set'
			if _type(data) != 'Function' then throw new Error 'Invalid second element of Set'

			stringIndex = 0
			stringsSet = ['']
			valuesSet = []

			PARAM = 'PARAM'
			useParam = (value) ->
				valuesToUse.push v
				return PARAM

			_addIndex(_map) data, (k, v) ->
				str = fn k, v, useParam
				strs = _split PARAM, str

				# v = val0[flavor][k]
				# if flavor == 'update'
				# 	stringsToUse[valuesToUse.length] += "#{k} = "
				# 	if k != keys[keys.length-1] # is not last key
				# 		stringsToUse.splice valuesToUse.length+1, 0, ', '
				# 	valuesToUse.push v
				# else if flavor == 'insert'
				# 	if k == keys[0]
				# 		stringsToUse[valuesToUse.length] += "(#{_join(', ', keys)}) values ("
				# 		valuesToUse.push v
				# 	else
				# 		stringsToUse.splice valuesToUse.length, 0, ', '
				# 		if k == keys[keys.length-1] # is last key
				# 			stringsToUse[valuesToUse.length+1] += ")"
				# 		valuesToUse.push v


		else
			valuesToUse.push val


	ret = ''
	for str, i in stringsToUse
		if i == 0 then ret += "#{if _isNil(str) then '' else str}"
		else ret += "$#{i}#{if _isNil(str) then '' else str}"

	return [ret, valuesToUse, stringsToUse]


