import path from "ramda/es/path"; #auto_require: esramda
import {} from "ramda-extras" #auto_require: esramda-extras

import assert from 'assert'

import * as cutils from './clientUtils'

import {deepEq} from '../shared/testUtils'

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
