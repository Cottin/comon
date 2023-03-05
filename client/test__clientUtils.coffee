 #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras

import * as cutils from './clientUtils'

import {deepEq} from '../shared/testUtils'

describe 'clientUtils', () ->
	describe 'fromUrl', () ->
		it 'full', () ->
			res = cutils.fromUrl '/p/q/r?a=1&b=2'
			deepEq {path0: 'p', path1: 'q', path2: 'r', a: 1, b: 2}, res

		it 'no query', () ->
			res = cutils.fromUrl '/p/q/r'
			deepEq {path0: 'p', path1: 'q', path2: 'r'}, res

		it 'no paths', () ->
			res = cutils.fromUrl '?a=1&b=2'
			deepEq {a: 1, b: 2}, res

	describe 'toUrl', () ->
		it 'full', () ->
			res = cutils.toUrl {path0: 'p', path1: 'q', path2: 'r', a: 1, b: 2}
			deepEq '/p/q/r?a=1&b=2', res

		it 'no query', () ->
			res = cutils.toUrl {path0: 'p', path1: 'q', path2: 'r'}
			deepEq '/p/q/r', res

		it 'no paths', () ->
			res = cutils.toUrl {a: 1, b: 2}
			deepEq '?a=1&b=2', res
