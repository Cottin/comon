import _isEmpty from "ramda/es/isEmpty"; import _isNil from "ramda/es/isNil"; import _type from "ramda/es/type"; #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras

export validateDelta = (delta) ->
  console.log delta 
  if _type(delta) != 'Object' then throw new Error "delta need to be object"
  if _isEmpty delta then throw new Error "delta cannot be empty"

export validateCtx = (ctx) ->
  if _isNil(ctx) || _isNil(ctx.cid) || isNaN(ctx.cid) then throw new FaultError "ctx has invalid cid.
  [ctx]: #{JSON.stringify(ctx)}"

export validateEntityId = (id) ->
  if _isNil(id) || isNaN(id) then throw new FaultError "invalid entity id: #{id}"
