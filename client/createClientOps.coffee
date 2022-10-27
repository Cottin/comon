import find from "ramda/es/find"; import findIndex from "ramda/es/findIndex"; import isEmpty from "ramda/es/isEmpty"; import isNil from "ramda/es/isNil"; import last from "ramda/es/last"; import move from "ramda/es/move"; import sort from "ramda/es/sort"; import type from "ramda/es/type"; import update from "ramda/es/update"; import where from "ramda/es/where"; import whereEq from "ramda/es/whereEq"; #auto_require: esramda
import {change, mapO, $} from "ramda-extras" #auto_require: esramda-extras
[ːup, ːsort〳1, ːdown, ːABORT, ːid] = ['up', 'sort〳1', 'down', 'ABORT', 'id'] #auto_sugar
_ = (...xs) -> xs

# import xhr from '../lib/xhr'


export default createClientOps = ({runLocal, setHUD}, def) ->

	deltaToServer = (entity, id, clientDelta, msg = null) ->
		serverDelta = await xhr.popsiqlApi.post {DELTA: clientDelta}
		if msg then setHUD app, msg
		normDelta = change serverDelta, clientDelta
		return {normDelta, delta: normDelta[entity][id]}

	$ def, mapO (ops, entity) ->
		$ ops, mapO (conf, op) ->
			switch op
				when 'create'
					(id, delta, msg = null) ->
						ensureId id
						clientDelta = {[entity]: {[id]: {id, ...delta}}}
						return deltaToServer entity, id, clientDelta, msg
				when 'update'
					(id, delta, msg = null) ->
						ensureId id
						clientDelta = {[entity]: {[id]: {id, ...delta}}}
						return deltaToServer entity, id, clientDelta, msg
				when 'delete'
					(id, msg = null) ->
						ensureId id
						clientDelta = {[entity]: {[id]: undefined}}
						return deltaToServer entity, id, clientDelta, msg
				when 'move'
					(id, upOrDown, where, msg = null) ->
						ensureId id
						if !contains upOrDown, [ːup, ːdown] then throw new FaultError "Can only move up/down: #{upOrDown}"
						list = runLocal {[entity]: _ {ːid, ːsort〳1, ...where}}
						idx = findIndex whereEq({id}), list
						if idx == -1 then throw new FaultError "Cannot find #{id} in list for moving"
						if idx == 0 && upOrDown == 'up' then return ːABORT
						else if idx == list.length - 1 && upOrDown == 'down' then return ːABORT
						self = list[idx]
						other = if upOrDown == ːup then list[idx-1] else list[idx+1]
						if isNil(self.sort) || isNil(other.sort) then throw new FaultError "Sort cannot be nil for move"
						clientDelta = {[entity]: {[self.id]: {sort: other.sort}, [other.id]: {sort: self.sort}}}
						return deltaToServer entity, id, clientDelta, msg
				when 'restore'
					(id, msg = null, where = {archived: false}) ->
						ensureId id
						list = runLocal {[entity]: _ {ːid, ːsort〳1, ...where}}
						newSort = if isEmpty list then 0 else last(list).sort + 1
						clientDelta = {[entity]: {[id]: {archived: false, sort: newSort}}}
						return deltaToServer entity, id, clientDelta, msg
				else
					if type(conf) == 'Function' || type(conf) == 'AsyncFunction'
						conf
					else throw new COE "no valid operation for #{op}"



ensureId = (id) ->
	if isNil(id) || isNaN(id)
		throw new Error "Invalid id: #{id}"














