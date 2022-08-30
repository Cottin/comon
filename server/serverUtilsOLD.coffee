# TOGO : för om till import 
http = require 'http'

handleError = (err) ->
  #todo... code: Math.random().toString(36).slice(-5)


validateDelta = (delta) ->
  if type(delta) != 'Object' then throw new Error "delta need to be object"
  if isEmpty delta then throw new Error "delta cannot be empty"

validateCtx = (ctx) ->
  if isNil(ctx) || isNil(ctx.cid) || isNaN(ctx.cid) then throw new FaultError "ctx has invalid cid.
  [ctx]: #{JSON.stringify(ctx)}"

validateEntityId = (id) ->
  if isNil(id) || isNaN(id) then throw new FaultError "invalid entity id: #{id}"

httpGet = (url) ->
  return new Promise (resolve) ->
    http.get url, (res) ->
      res.setEncoding "utf8"
      body = ""
      res.on 'data', (chunk) -> body += chunk
      res.on 'end', () ->
        data = JSON.parse body
        resolve data

ipCheck = (req) ->
  # return {country: 'FR', address: '123.123.123.123'} # for local testing
  # assumes middleware request-ip is used
  if length(req.clientIp) < 5 || test(/127\.0\.0\.1/, req.clientIp)
    return {country: null, address: req.clientIp} # eg. ::1 on dev machine = don't spend a lookup
  result = await httpGet "http://api.ipstack.com/#{req.clientIp}?access_key=#{process.env.IP_STACK_API_KEY}"
  return {country: result.country_code, address: req.clientIp}

trycatch = (promise) ->
  try
    res = await promise
    return res
  catch err
    return undefined

