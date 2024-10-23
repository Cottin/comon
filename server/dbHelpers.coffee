import _addIndex from "ramda/es/addIndex"; import _clone from "ramda/es/clone"; import _hasIn from "ramda/es/hasIn"; import _includes from "ramda/es/includes"; import _isEmpty from "ramda/es/isEmpty"; import _isNil from "ramda/es/isNil"; import _keys from "ramda/es/keys"; import _map from "ramda/es/map"; import _mapObjIndexed from "ramda/es/mapObjIndexed"; import _replace from "ramda/es/replace"; import _split from "ramda/es/split"; import _toLower from "ramda/es/toLower"; import _toUpper from "ramda/es/toUpper"; import _type from "ramda/es/type"; #auto_require: _esramda
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
		if _type(strings2) == 'String' && _isEmpty(values)
			# allow for raw values - but developer responsible for quoting/escaping/sql-injections
			firstResult[0] += strings2
			firstResult[2][firstResult[2].length - 1] += strings2
			return this


		additionalResult = prepareWithParamsRaw firstResult[1].length, strings2, values...
		firstResult[0] += additionalResult[0]
		firstResult[1].push additionalResult[1]...

		# we need to merge the last string of previous result with first string of next result
		firstResult[2][firstResult[2].length - 1] += additionalResult[2][0]

		firstResult[2].push additionalResult[2].slice(1)...
		return this

	return firstResult

export sql = prepareWithParamsRecursive # just an alias


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


export ensurePrepareResult = (prepareResult) ->
	if _type(prepareResult) != 'Array' || prepareResult.length != 3 || !prepareResult.add || _type(prepareResult.add) != 'Function'
		throw new Error 'Are you trying to call run with a string?'

	return prepareResult



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


# https://www.postgresql.org/docs/8.1/sql-keywords-appendix.html
# All except "non-reserved" from list
keywords = ['A', 'ABS', 'ADA', 'ALIAS', 'ALL', 'ALLOCATE', 'ALWAYS', 'ANALYSE', 'ANALYZE', 'AND', 'ANY', 'ARE', 'ARRAY', 'AS', 'ASC', 'ASENSITIVE', 'ASYMMETRIC', 'ATOMIC', 'ATTRIBUTE', 'ATTRIBUTES', 'AUTHORIZATION', 'AVG', 'BERNOULLI', 'BETWEEN', 'BINARY', 'BITVAR', 'BIT_LENGTH', 'BLOB', 'BOTH', 'BREADTH', 'C', 'CALL', 'CARDINALITY', 'CASCADED', 'CASE', 'CAST', 'CATALOG', 'CATALOG_NAME', 'CEIL', 'CEILING', 'CHARACTERS', 'CHARACTER_LENGTH', 'CHARACTER_SET_CATALOG', 'CHARACTER_SET_NAME', 'CHARACTER_SET_SCHEMA', 'CHAR_LENGTH', 'CHECK', 'CHECKED', 'CLASS_ORIGIN', 'CLOB', 'COBOL', 'COLLATE', 'COLLATION', 'COLLATION_CATALOG', 'COLLATION_NAME', 'COLLATION_SCHEMA', 'COLLECT', 'COLUMN', 'COLUMN_NAME', 'COMMAND_FUNCTION', 'COMMAND_FUNCTION_CODE', 'COMPLETION', 'CONDITION', 'CONDITION_NUMBER', 'CONNECT', 'CONNECTION_NAME', 'CONSTRAINT', 'CONSTRAINT_CATALOG', 'CONSTRAINT_NAME', 'CONSTRAINT_SCHEMA', 'CONSTRUCTOR', 'CONTAINS', 'CONTINUE', 'CORR', 'CORRESPONDING', 'COUNT', 'COVAR_POP', 'COVAR_SAMP', 'CREATE', 'CROSS', 'CUBE', 'CUME_DIST', 'CURRENT', 'CURRENT_DATE', 'CURRENT_DEFAULT_TRANSFORM_GROUP', 'CURRENT_PATH', 'CURRENT_ROLE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_TRANSFORM_GROUP_FOR_TYPE', 'CURRENT_USER', 'CURSOR_NAME', 'DATA', 'DATE', 'DATETIME_INTERVAL_CODE', 'DATETIME_INTERVAL_PRECISION', 'DEFAULT', 'DEFERRABLE', 'DEFINED', 'DEGREE', 'DENSE_RANK', 'DEPTH', 'DEREF', 'DERIVED', 'DESC', 'DESCRIBE', 'DESCRIPTOR', 'DESTROY', 'DESTRUCTOR', 'DETERMINISTIC', 'DIAGNOSTICS', 'DICTIONARY', 'DISCONNECT', 'DISPATCH', 'DISTINCT', 'DO', 'DYNAMIC', 'DYNAMIC_FUNCTION', 'DYNAMIC_FUNCTION_CODE', 'ELEMENT', 'ELSE', 'END', 'END-EXEC', 'EQUALS', 'EVERY', 'EXCEPT', 'EXCEPTION', 'EXCLUDE', 'EXEC', 'EXISTING', 'EXP', 'FALSE', 'FILTER', 'FINAL', 'FLOOR', 'FOLLOWING', 'FOR', 'FOREIGN', 'FORTRAN', 'FOUND', 'FREE', 'FREEZE', 'FROM', 'FULL', 'FUSION', 'G', 'GENERAL', 'GENERATED', 'GET', 'GO', 'GOTO', 'GRANT', 'GROUP', 'GROUPING', 'HAVING', 'HIERARCHY', 'HOST', 'IDENTITY', 'IGNORE', 'ILIKE', 'IMPLEMENTATION', 'IN', 'INDICATOR', 'INFIX', 'INITIALIZE', 'INITIALLY', 'INNER', 'INSTANCE', 'INSTANTIABLE', 'INTERSECT', 'INTERSECTION', 'INTO', 'IS', 'ISNULL', 'ITERATE', 'JOIN', 'K', 'KEY_MEMBER', 'KEY_TYPE', 'LATERAL', 'LEADING', 'LEFT', 'LENGTH', 'LESS', 'LIKE', 'LIMIT', 'LN', 'LOCALTIME', 'LOCALTIMESTAMP', 'LOCATOR', 'LOWER', 'M', 'MAP', 'MATCHED', 'MAX', 'MEMBER', 'MERGE', 'MESSAGE_LENGTH', 'MESSAGE_OCTET_LENGTH', 'MESSAGE_TEXT', 'METHOD', 'MIN', 'MOD', 'MODIFIES', 'MODIFY', 'MODULE', 'MORE', 'MULTISET', 'MUMPS', 'NAME', 'NATURAL', 'NCLOB', 'NESTING', 'NEW', 'NORMALIZE', 'NORMALIZED', 'NOT', 'NOTNULL', 'NULL', 'NULLABLE', 'NULLS', 'NUMBER', 'OCTETS', 'OCTET_LENGTH', 'OFF', 'OFFSET', 'OLD', 'ON', 'ONLY', 'OPEN', 'OPERATION', 'OPTIONS', 'OR', 'ORDER', 'ORDERING', 'ORDINALITY', 'OTHERS', 'OUTER', 'OUTPUT', 'OVER', 'OVERLAPS', 'OVERRIDING', 'PAD', 'PARAMETER', 'PARAMETERS', 'PARAMETER_MODE', 'PARAMETER_NAME', 'PARAMETER_ORDINAL_POSITION', 'PARAMETER_SPECIFIC_CATALOG', 'PARAMETER_SPECIFIC_NAME', 'PARAMETER_SPECIFIC_SCHEMA', 'PARTITION', 'PASCAL', 'PATH', 'PERCENTILE_CONT', 'PERCENTILE_DISC', 'PERCENT_RANK', 'PLACING', 'PLI', 'POSTFIX', 'POWER', 'PRECEDING', 'PREFIX', 'PREORDER', 'PRIMARY', 'PUBLIC', 'RANGE', 'RANK', 'READS', 'RECURSIVE', 'REF', 'REFERENCES', 'REFERENCING', 'REGR_AVGX', 'REGR_AVGY', 'REGR_COUNT', 'REGR_INTERCEPT', 'REGR_R2', 'REGR_SLOPE', 'REGR_SXX', 'REGR_SXY', 'REGR_SYY', 'RESULT', 'RETURN', 'RETURNED_CARDINALITY', 'RETURNED_LENGTH', 'RETURNED_OCTET_LENGTH', 'RETURNED_SQLSTATE', 'RIGHT', 'ROLLUP', 'ROUTINE', 'ROUTINE_CATALOG', 'ROUTINE_NAME', 'ROUTINE_SCHEMA', 'ROW_COUNT', 'ROW_NUMBER', 'SCALE', 'SCHEMA_NAME', 'SCOPE', 'SCOPE_CATALOG', 'SCOPE_NAME', 'SCOPE_SCHEMA', 'SEARCH', 'SECTION', 'SELECT', 'SELF', 'SENSITIVE', 'SERVER_NAME', 'SESSION_USER', 'SETS', 'SIMILAR', 'SIZE', 'SOME', 'SOURCE', 'SPACE', 'SPECIFIC', 'SPECIFICTYPE', 'SPECIFIC_NAME', 'SQL', 'SQLCODE', 'SQLERROR', 'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING', 'SQRT', 'STATE', 'STATIC', 'STDDEV_POP', 'STDDEV_SAMP', 'STRUCTURE', 'STYLE', 'SUBCLASS_ORIGIN', 'SUBLIST', 'SUBMULTISET', 'SUM', 'SYMMETRIC', 'SYSTEM_USER', 'TABLE', 'TABLESAMPLE', 'TABLE_NAME', 'TERMINATE', 'THAN', 'THEN', 'TIES', 'TIMEZONE_HOUR', 'TIMEZONE_MINUTE', 'TO', 'TOP_LEVEL_COUNT', 'TRAILING', 'TRANSACTIONS_COMMITTED', 'TRANSACTIONS_ROLLED_BACK', 'TRANSACTION_ACTIVE', 'TRANSFORM', 'TRANSFORMS', 'TRANSLATE', 'TRANSLATION', 'TRIGGER_CATALOG', 'TRIGGER_NAME', 'TRIGGER_SCHEMA', 'TRUE', 'UESCAPE', 'UNBOUNDED', 'UNDER', 'UNION', 'UNIQUE', 'UNNAMED', 'UNNEST', 'UPPER', 'USAGE', 'USER', 'USER_DEFINED_TYPE_CATALOG', 'USER_DEFINED_TYPE_CODE', 'USER_DEFINED_TYPE_NAME', 'USER_DEFINED_TYPE_SCHEMA', 'USING', 'VALUE', 'VARIABLE', 'VAR_POP', 'VAR_SAMP', 'VERBOSE', 'WHEN', 'WHENEVER', 'WHERE', 'WIDTH_BUCKET', 'WINDOW', 'WITHIN']
export esc = (s) -> if _includes _toUpper(s), keywords then "\"#{s}\"" else s
export camelToSnake = (s) -> $ s, _replace(/[A-Z]/g, (s) -> '_' + _toLower s)
export snakeToCamel = (s) -> $ s, _replace(/_[a-z]/g, (s) -> _toUpper s[1])
export pascalToSnake = (s) -> $ s, _replace(/^[A-Z]/g, (s) -> _toLower s), camelToSnake
