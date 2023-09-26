# Philosophy
# No need for an error code, instead make the message good enough for you to identify where error occured
# if a user reports it.


# Something in user input is not valid
export class ValidationError extends Error
	constructor: (message, meta, ...args) ->
		super(message, meta, ...args)
		@name = 'ValidationError'
		# eg. {email: true, password: true} for individual error messages and removal of them separatly.
		if meta then @meta = meta

# # Something in user input is not valid
# export class ValidationError2 extends Error
# 	constructor: (message, error, ...args) ->
# 		super(message, error, ...args)
# 		@name = 'ValidationError2'
# 		# eg. {email: true, password: true} for individual error messages and removal of them separatly.
# 		if error then @error = error
		
# Something is faulty with input data or stored data or similar but this is different from
# a ValidationError in that it shouldn't occur with correct application usage. Ie. if this is seen
# there is a chance it occured due to some bug or faulty usage of api by developer.
export class FaultError extends Error
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'FaultError'
		
# Something that should not occur and if it does, it should probably be investigated!
# Different from a FaultError in that those don't have to be investigated.
export class WeirdError extends Error
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'WeirdError'
		
# Something is not working in an integration with an external system, eg. payment provider, etc.
export class IntegrationError extends Error
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'IntegrationError'
		
# User not logged in
export class AuthError extends Error
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'AuthError'
		
# User not permitted to do something
export class PermissionError extends Error
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'PermissionError'

# DB-related error
export class DBError extends Error
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'DBError'

export stringifyError = (err) -> {name: err.name, message: err.message, meta: err.meta}
export parseError = (err) ->
	switch err.name
		when 'ValidationError' then new ValidationError err.message, err.meta
		when 'FaultError' then new FaultError err.message
		when 'WeirdError' then new WeirdError err.message
		when 'IntegrationError' then new IntegrationError err.message
		when 'AuthError' then new AuthError err.message
		when 'PermissionError' then new PermissionError err.message
		when 'DBError' then new DBError err.message
		else err
