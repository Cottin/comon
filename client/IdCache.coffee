import clone from "ramda/es/clone"; import has from "ramda/es/has"; import map from "ramda/es/map"; #auto_require: esramda
import {change, $} from "ramda-extras" #auto_require: esramda-extras



# Simple cache based on the structure:
# Entity:
#   id: {data}
# eg.
# Project:
#   10: {id: 10, name: 'New website'}
#
# and based on changes using ramda-extras change function:
#
# idCache.change {Project: {10: {name: 'Rebranding existing website'}}}
#
export default class IdCache
	constructor: ->
		@state = null
		@dirtyKeys = {}

	reset: (state = null) => @state = state

	# Note: can be expensive if delta is big map and state is big map, concider change {entity: always({..})}
	change: (_delta) =>
		delta = clone _delta

		# Handle id-changes
		# eg. {Project: {-1: {id: 11, name: 'Office rebrand'}}}
		for entity, delta2 of delta
			for id, delta3 of delta2
				if has('id', delta3) && id != delta3
					existingData = @state[entity]?[id]
					newData = {...existingData, ...delta3}
					delta[entity][id] = undefined
					delta[entity][newData.id] = newData

		@state = change delta, @state
		@dirtyKeys = {...@dirtyKeys, ...($ delta, map (-> true))}

	resetDirty: => @dirtyKeys = {}

