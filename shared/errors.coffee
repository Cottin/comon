# PHILOSOPHY
# Server side:	We want to be able to almost anywhere in the code throw an error that will break out from
#								whereever we are and log the message and the stack and finally return the message to the
#								client so that we can show it. So keep all error messages for custom errors user friendly and
#								"safe" to not expose anything sensitve.
#								At the same time we don't want any error to be returned to the client since they could include
#								sensitive information on a 500 crash or similar. Therefore it is expected that somewhere high
#								up in the code, there should be a try...catch block checking if error is of type CustomError
#								in which case it's deemed safe and returned to the client. If the error is of another type,
#								we expect instead that some general safe error message is returned to the client. If you want 
#								to throw an error that should not be returned to the client, throw a normal Error instead.
#
#	Client side:	We mostly recieve errors from the server and show them appropriatly. You can however throw
#								errors client side too, for instance in a validation function to check if the input is valid
#								and throw a ValidationError in order to make certain fields red.

export class CustomError extends Error
  constructor: (message) ->
    super message
    @name = @constructor.name
    if Error.captureStackTrace
      Error.captureStackTrace @, @constructor


# Something in user input is not valid
export class ValidationError extends CustomError
	constructor: (message, meta, ...args) ->
		super(message, meta, ...args)
		@name = 'ValidationError'
		# eg. {email: true, password: true} for individual error messages and removal of them separatly.
		if meta then @meta = meta

# # Something in user input is not valid
# export class ValidationError2 extends CustomError
# 	constructor: (message, error, ...args) ->
# 		super(message, error, ...args)
# 		@name = 'ValidationError2'
# 		# eg. {email: true, password: true} for individual error messages and removal of them separatly.
# 		if error then @error = error
		
# Something is faulty with input data or stored data or similar but this is different from
# a ValidationError in that it shouldn't occur with correct application usage. Ie. if this is seen
# there is a chance it occured due to some bug or faulty usage of api by developer.
export class FaultError extends CustomError
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'FaultError'
		
# Something that should not occur and if it does, it should probably be investigated!
# Different from a FaultError in that those don't have to be investigated.
export class WeirdError extends CustomError
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'WeirdError'
		
# Something is not working in an integration with an external system, eg. payment provider, etc.
export class IntegrationError extends CustomError
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'IntegrationError'
		
# User not logged in
export class AuthError extends CustomError
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'AuthError'
		
# User not permitted to do something
export class PermissionError extends CustomError
	constructor: (message, ...args) ->
		super(message, ...args)
		@name = 'PermissionError'

# DB-related error
export class DBError extends CustomError
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
