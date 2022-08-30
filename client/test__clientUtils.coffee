path = require('ramda/src/path'); #auto_require: srcramda
import {} from "ramda-extras" #auto_require: esramda-extras

import assert from 'assert'

import * as cutils from './clientUtils'

# TODO - flytta till testhelp
deepEq = (a, b, c) ->
  assert.deepStrictEqual(b, a, c)
deepEq_ = (a, b, c) ->
  console.log b
  assert.deepStrictEqual(b, a, c)
fdeepEq = (a, b, c) ->
  assert.deepStrictEqual(a, b, c)
fdeepEq_ = (a, b, c) ->
  console.log a
  assert.deepStrictEqual(a, b, c)
eq = (a, b, c) ->
  assert.strictEqual(b, a, c)
eq_ = (a, b, c) ->
  console.log b
  assert.strictEqual(b, a, c)
feq = (a, b, c) ->
  assert.strictEqual(a, b, c)
feq_ = (a, b, c) ->
  console.log a
  assert.strictEqual(a, b, c)

describe 'clientUtils', () ->
  describe 'url', () ->
    it '1', () ->
      res = cutils.fromUrl '/p/q/r?a=1&b=2'
      deepEq {path0: 'p', path1: 'q', path2: 'r', a: 1, b: 2}, res

    it '2', () ->
      res = cutils.fromUrl '/p/q/r'
      deepEq {path0: 'p', path1: 'q', path2: 'r'}, res

    it '3', () ->
      res = cutils.fromUrl '?a=1&b=2'
      deepEq {a: 1, b: 2}, res
