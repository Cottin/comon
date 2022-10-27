import empty from "ramda/es/empty"; import has from "ramda/es/has"; import isEmpty from "ramda/es/isEmpty"; import isNil from "ramda/es/isNil"; import type from "ramda/es/type"; #auto_require: esramda
import {} from "ramda-extras" #auto_require: esramda-extras

export validateDelta = (delta) ->
  console.log delta 
  if type(delta) != 'Object' then throw new Error "delta need to be object"
  if isEmpty delta then throw new Error "delta cannot be empty"

export validateCtx = (ctx) ->
  if isNil(ctx) || isNil(ctx.cid) || isNaN(ctx.cid) then throw new FaultError "ctx has invalid cid.
  [ctx]: #{JSON.stringify(ctx)}"

export validateEntityId = (id) ->
  if isNil(id) || isNaN(id) then throw new FaultError "invalid entity id: #{id}"
