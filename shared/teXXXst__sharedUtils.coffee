test = require('ramda/src/test'); #auto_require: srcramda
import {$} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar

import assert from 'assert'
import * as q from './sharedUtils'

import {eq, throws, throws_} from 'testhelp'

# TODO - flytta till testhelp
deepEq = (a, b, c) ->
  assert.deepStrictEqual(b, a, c)

describe 'sharedUtils', () ->
  describe 'test1', () ->
    it '1', () ->
      deepEq 'orno-brygga', q.toUrlFriendly 'Ornö brygga'

  describe 'formatNumber', () ->
    it '1', () -> eq '23.12', q.formatNumber 23.1234
    it '2', () -> eq '23', q.formatNumber 23.00, true
    it '3', () -> eq '23.12346', q.formatNumber 23.123456, true, 5


  describe 'formatCurrency', -> # NOTE: Spaces below are not normal spaces
    it '1', -> eq '1 500,99 kr', q.formatCurrency 150099, 'SE'
    it '2', -> eq '1 500,00 kr', q.formatCurrency 150000, 'SE'
    it '3', -> eq '1 500 kr', q.formatCurrency 150000, 'SE', true
    it '4', -> eq '$99.50', q.formatCurrency 9950, 'US'
    it '5', -> eq '$99.50', q.formatCurrency 9950, 'US', true
    it '6', -> eq '$99', q.formatCurrency 9900, 'US', true

  describe 'toHMM + fromHHMMorDec', ->
    it 'easy', -> eq '0:30', q.toHMM 0.5
    it 'hard', -> eq '4:05', q.toHMM 4.083333333333333
    it 'null', -> eq null, q.toHMM null

    it '.', -> eq 4.33, q.fromHHMMorDec '4.33'
    it ':', -> eq 4.083333333333333, q.fromHHMMorDec '4:05'
    it ',', -> eq 4.33, q.fromHHMMorDec '4,33'

    it 'abc', -> eq null, q.fromHHMMorDec 'abc'

    it '4:', -> eq 4, q.fromHHMMorDec '4:'
    it ':23', -> eq 0.4, q.fromHHMMorDec ':24'
    it ': alone', -> eq null, q.fromHHMMorDec ':'
