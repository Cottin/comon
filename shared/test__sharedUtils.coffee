test = require('ramda/src/test'); #auto_require: srcramda
import {$} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar

import * as q from './sharedUtils'

import {eq, deepEq} from '../shared/testUtils'


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

  describe 'formatPeriod', ->
    now = new Date('2021-01-01')
    it 'month same', -> deepEq ['month', 'JAN'], q.formatPeriod '2021-01-01', '2021-01-31', now
    it 'month', -> deepEq ['month', 'JAN 2020'], q.formatPeriod '2020-01-01', '2020-01-31', now
    it 'week same', -> deepEq ['week', 'May 3 - 9'], q.formatPeriod '2021-05-03', '2021-05-09', now
    it 'week', -> deepEq ['week', 'Apr 26 - May 2'], q.formatPeriod '2021-04-26', '2021-05-02', now
    it 'quarter', -> deepEq ['quarter', 'Q2 2021'], q.formatPeriod '2021-04-01', '2021-06-30', now
    it 'year', -> deepEq ['year', '2021'], q.formatPeriod '2021-01-01', '2021-12-31', now

    it '7', -> deepEq ['week', 'Jul 6 - 12 2020'], q.formatPeriod '2020-07-06', '2020-07-12', now
    it '8', -> deepEq ['custom', 'May 3 - May 10'], q.formatPeriod '2021-05-03', '2021-05-10', now

    it '0', -> deepEq [null, 'Invalid period'], q.formatPeriod '2021-07-06', '2020-07-12', now
    it '8', -> deepEq [null, 'Invalid start date'], q.formatPeriod '2021-02-32', '2021-07-12', now
    it '9', -> deepEq [null, 'Invalid end date'], q.formatPeriod '2021-01-06', '2021-02-30', now

    it '10', -> deepEq ['month', 'JAN 2020'], q.formatPeriod '2020-01-01', '2020-01-31', now
    it '11', -> deepEq ['quarter', 'Q2 2020'], q.formatPeriod '2020-04-01', '2020-06-30', now
    it '12', -> deepEq ['year', '2020'], q.formatPeriod '2020-01-01', '2020-12-31', now

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

  describe 'df', () ->
    describe 'weekStartEnd', () ->
      it '1', () -> deepEq {start: '2022-07-25', end: '2022-07-31'}, q.df.weekStartEnd '2022w30'
      it '2', () -> deepEq {start: '2022-08-29', end: '2022-09-04'}, q.df.weekStartEnd '2022w35'
      it '3', () -> deepEq {start: '2022-10-31', end: '2022-11-06'}, q.df.weekStartEnd '2022w44'
      it '4', () -> deepEq {start: '2022-12-26', end: '2023-01-01'}, q.df.weekStartEnd '2022w52'
      it '5', () -> deepEq {start: '2023-01-02', end: '2023-01-08'}, q.df.weekStartEnd '2023w1'

    describe 'cheapWeek', () ->
      it '1', () ->
        # deepEq 30, q.df.cheapWeek '2022-07-25'
        # deepEq 30, q.df.cheapWeek '2022-07-31'
        deepEq 30, q.df.format 'W', '2022-07-31'
      # it '2', () -> deepEq {start: '2022-08-29', end: '2022-09-04'}, q.df.cheapWeek '2022w35'
      # it '3', () -> deepEq {start: '2022-10-31', end: '2022-11-06'}, q.df.cheapWeek '2022w44'
      # it '4', () -> deepEq {start: '2022-12-26', end: '2023-01-01'}, q.df.cheapWeek '2022w52'
      # it '5', () -> deepEq {start: '2023-01-02', end: '2023-01-08'}, q.df.cheapWeek '2023w1'

    describe 'opti', () ->
      describe 'startOfWeek', () ->
        it '1', () -> eq '2022-12-05', q.df.opti.startOfWeek '2022-12-09'
        it '2', () -> eq '2022-12-26', q.df.opti.startOfWeek '2023-01-01'
