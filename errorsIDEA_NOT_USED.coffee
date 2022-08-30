import init from "ramda/es/init"; import last from "ramda/es/last"; import match from "ramda/es/match"; import split from "ramda/es/split"; import trim from "ramda/es/trim"; import type from "ramda/es/type"; #auto_require: esramda
import {$} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar
qq = (f) -> console.log match(/return (.*);/, f.toString())[1], f()
qqq = (...args) -> console.log ...args
_ = (...xs) -> xs

# Trying new style: just write error type in message with !, eg. regex ^(.*)! should match

possibleErrors = () ->
	# Something in user input is not valid
	new Error 'Validation: Missing name'

	# Something is faulty with input data or stored data or similar but this is different from
	# a ValidationError in that it shouldn't occur with correct application usage. Ie. if this is seen
	# there is a chance it occured due to some bug or faulty usage of api by developer.
	new Error 'Fault: Missing user'

	# Something that should not occur and if it does, it should probably be investigated!
	# Different from a FaultError in that those don't have to be investigated.
	new Error 'Weird: No context'

	# Something is not working in an integration with an external system, eg. payment provider, etc.
	new Error 'Integration: Partner did not respond'

	# User not logged in
	new Error 'Auth: You are not logged in'

	# User not permitted to do something
	new Error 'Permission: Not allowed to do that'

	# DB-related error
	new Error 'DB: No response'


# Specification:  grand-child:child:error-type: Error message [optional error code]
# Example:        Server:Integration:Validation: Invalid credit card [a2aS3q]
export decodeError = (errMsg) ->
	# https://regex101.com/r/lqct2r/1
	[___, types, msg, code] = match /^(\S*):(.*?)(?:\[(.*)\])?$/, errMsg

	if types
		typesSplit = $ types, split(':')
		parents = init typesSplit
		type = last typesSplit
	else 
		parents = type = undefined

	return {type, msg: trim(msg), code, parents, raw: errMsg}
