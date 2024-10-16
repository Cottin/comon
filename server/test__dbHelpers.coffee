 #auto_require: _esramda
import {$} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar

import * as dbHelpers from './dbHelpers'

import {eq, deepEq, throws, its} from '../shared/testUtils'

describe 'dbUtils', () ->
	describe 'prepareWithParams', () ->
		fn = (...args) -> dbHelpers.prepareWithParams(args...).slice 0, 2
		fn2 = (...args) -> dbHelpers.prepareWithParams(args...)
		recPrep = (...args) -> dbHelpers.prepareWithParamsRecursive(args...)
		its -> deepEq ['a$1b$2c', [1, 2]], fn"a#{1}b#{2}c"
		its -> deepEq ['select * from table where id = $1', [9]], fn"select * from table where id = #{9}"
		its -> throws 'as a function', -> fn "a #{1}"

		# Set 
		its -> throws 'Invalid size', -> fn"a#{1} #{new Set([1])} where id = #{9}"
		its -> throws 'Invalid type of 0', -> fn"a#{1} #{new Set([1, () -> ])} where id = #{9}"
		its -> throws 'Invalid type of 1', -> fn"a#{1} #{new Set([{a: 1}, 1])} where id = #{9}"
		its -> throws 'useParam more', -> fn"a#{1} #{new Set([{a: 1}, (k, v, p) -> p(v)+p(v)])}"

		its -> deepEq ['a$1, b2, c$2., d$3., e$4',
			[1, 3, 4, 5],
			['a', ', b2, c', '., d', '., e', '']],
			fn2"a#{1}, b2, #{new Set([{c: 3, d: 4}, (k, v, p) -> "#{k}#{p(v)}."])}, e#{5}"

		its -> deepEq ['a$1, b2, c$2', [1, 3], ['a', ', b2, c', '']], fn2"a#{1}, b2, c#{3}"

		its -> deepEq ['a$1, b2, c$2, d$3, e5, f$4', [1, 3, 4, 6], ['a', ', b2, c', ', d', ', e5, f', '']], recPrep"a#{1}, b2, c#{3}".add", d#{4}, e5, f#{6}".slice 0, 3

		its -> deepEq ['$1, b2, c$2!$3, e5, f$4!', [1, 3, 4, 6], ['', ', b2, c', '!', ', e5, f', '!']], recPrep"#{1}, b2, c#{3}!".add"#{4}, e5, f#{6}!".slice 0, 3

		its -> deepEq ['a$1, b2, c$2, d$3, e5, f$4', [1, 3, 4, 6], ['a', ', b2, c', ', d', ', e5, f', '']], recPrep"a#{1}, b2".add", c#{3}".add", d#{4}, e5, f#{6}".slice 0, 3

		its -> deepEq ['update top($1) table set name = $2, age = $3 where id = $4', [1, 'bob', 5, 9]],
			fn"update top(#{1}) table set
			#{new Set([{name: 'bob', age: 5}, (k, v, p) -> "#{k} = #{p(v)}"])} where id = #{9}"

		its -> deepEq ['name = $1, age = $2', ['bob', 5]],
			fn"#{new Set([{name: 'bob', age: 5}, (k, v, p) -> "#{k} = #{p(v)}"])}"

		its -> deepEq ['name, age = $1, $2...', ['bob', 5]],
			fn"#{new Set([{name: 'bob', age: 5}, (k, v, p) -> k])} =
			#{new Set([{name: 'bob', age: 5}, (k, v, p) -> p(v)])}..."

		its -> deepEq ['update top($1) table set name = $2, age = $3 where id = $4',
			[1, 'bob', 5, 9],
			['update top(', ') table set name = ', ', age = ', ' where id = ', '']],
			fn2"update top(#{1}) table set
			#{new Set([{name: 'bob', age: 5}, (k, v, p) -> "#{k} = #{p(v)}"])} where id = #{9}"

		its -> deepEq ['insert into table (name, age) values ($1, $2)',
			['bob', 5],
			['insert into table (name, age) values (', ', ', ')']],
			fn2"insert into table
			(#{new Set([{name: 'bob', age: 5}, (k, v, p) -> k])}) values
			(#{new Set([{name: 'bob', age: 5}, (k, v, p) -> p(v)])})"
