import _filter from "ramda/es/filter"; import _map from "ramda/es/map"; import _whereEq from "ramda/es/whereEq"; #auto_require: _esramda
import {$} from "ramda-extras" #auto_require: esramda-extras

os = [{id: 1, name: 'a', type: 'x'}, {id: 2, name: 'b', type: 'y'}, {id: 3, name: 'b', type: 'x'}]

# Fyll i denna allt eftersom exempel kommer upp i riktigt scenarion

# Åsikter
# - Tycker $ os, .., .. är mer läsbart än os.......


# Saker undersöka
# - 

import {eq} from '../shared/testUtils'


describe 'fun', () ->
	it 'filter, map', () ->
		console.log $ os, _filter(_whereEq({type: 'x'})), _map (o) -> o
		console.log os.filter((o) -> o.type == 'x').map (o) -> o
