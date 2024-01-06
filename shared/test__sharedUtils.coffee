empty = require('ramda/src/empty'); max = require('ramda/src/max'); min = require('ramda/src/min'); test = require('ramda/src/test'); #auto_require: srcramda
import {$} from "ramda-extras" #auto_require: esramda-extras
[] = [] #auto_sugar

import * as q from './sharedUtils'

import {eq, deepEq, throws} from '../shared/testUtils'


describe 'sharedUtils', () ->
	describe 'test1', () ->
		it '1', () ->
			deepEq 'orno-brygga', q.toUrlFriendly 'Ornö brygga'

	describe 'formatNumber', () ->
		it '1', () -> eq '23.12', q.formatNumber 23.1234
		it '2', () -> eq '23', q.formatNumber 23.00, true
		it '3', () -> eq '23.12346', q.formatNumber 23.123456, true, 5

	# nonBreakingSpace = ' ' # use this in tests for currencies

	describe 'defaultFormattingFor', () ->
		fUS = q.defaultFormattingFor 'US'
		it 'SE', () -> 
			fSE = q.defaultFormattingFor 'SE'
			deepEq {currencyBefore: false, currencySymbol: 'kr', currencySpace: true, decimalPoint: ',', thousandSeparator: ' '}, fSE

		it 'US', () -> 
			fUS = q.defaultFormattingFor 'US'
			deepEq {currencyBefore: true, currencySymbol: '$', currencySpace: false, decimalPoint: '.', thousandSeparator: ','}, fUS

	describe.only 'formatNumberFast', () ->
		fSE = q.defaultFormattingFor 'SE'
		fUS = q.defaultFormattingFor 'US'
		it '1', () -> eq '12 345 678,1234', q.formatNumberFast 12345678.12345, {form: fSE, toFixed: 4}
		it '2', () -> eq '12 345 678', q.formatNumberFast 12345678.12345, {form: fSE, toFixed: 0}
		it '3', () -> eq '123,4', q.formatNumberFast 123.4, {form: fSE, toFixed: 1}
		it '4', () -> eq '12 345 678,12 kr', q.formatNumberFast 12345678.12345, {form: fSE, toFixed: 2, currency: 'symbol'}
		it '5', () -> eq '123,00', q.formatNumberFast 123, {form: fSE, toFixed: 2}
		it '6', () -> eq '123', q.formatNumberFast 123, {form: fSE, toFixed: 2, removeZero: true}
		it '7', () -> eq '$4,638', q.formatNumberFast 4638.00, {form: fUS, removeZero: true, currency: 'symbol'}
		it '1 US', () -> eq '12,345,678.1234', q.formatNumberFast 12345678.12345, {form: fUS, toFixed: 4}
		it '4 US', () -> eq '$12,345,678.12', q.formatNumberFast 12345678.12345, {form: fUS, toFixed: 2, currency: 'symbol'}
		it 'AZ (Azarbajan, tests fallbacks)', () -> eq 'AZN', q.defaultFormattingFor('AZ').currencySymbol
		it '3 SE separate', () -> deepEq [null, '123,4 ', 'kr'], q.formatNumberFast 123.4, {form: fSE, toFixed: 1, currency: 'separate'}
		it '3 US separate', () -> deepEq ['$', '123.4', null], q.formatNumberFast 123.4, {form: fUS, toFixed: 1, currency: 'separate'}
		it '3 SE separateTrim', () -> deepEq [null, '123,4', 'kr'], q.formatNumberFast 123.4, {form: fSE, toFixed: 1, currency: 'separateTrim'}

	describe 'formatBigNumber', () ->
		it '1', () -> eq '100 k', q.formatBigNumber 100410

	describe 'formatCurrency', -> # NOTE: Spaces below are not normal spaces
		it '1', -> eq '1 500,99 kr', q.formatCurrency 150099, 'SE'
		it '2', -> eq '1 500,00 kr', q.formatCurrency 150000, 'SE'
		it '3', -> eq '1 500 kr', q.formatCurrency 150000, 'SE', true
		it '4', -> eq '$99.50', q.formatCurrency 9950, 'US'
		it '5', -> eq '$99.50', q.formatCurrency 9950, 'US', true
		it '6', -> eq '$99', q.formatCurrency 9900, 'US', true

	describe 'formatPeriod', ->
		now = new Date('2021-01-01')
		it 'empty options', -> deepEq ['month', 'Jan 2021'], q.formatPeriod '2021-01-01', '2021-01-31'
		it 'month same', -> deepEq ['month', 'Jan'], q.formatPeriod '2021-01-01', '2021-01-31', {now}
		it 'month', -> deepEq ['month', 'Jan 2020'], q.formatPeriod '2020-01-01', '2020-01-31', {now}
		it 'week same', -> deepEq ['week', 'May 3 - 9'], q.formatPeriod '2021-05-03', '2021-05-09', {now}
		it 'week', -> deepEq ['week', 'Apr 26 - May 2'], q.formatPeriod '2021-04-26', '2021-05-02', {now}
		it 'quarter', -> deepEq ['quarter', 'Q2 2021'], q.formatPeriod '2021-04-01', '2021-06-30', {now}
		it 'year', -> deepEq ['year', '2021'], q.formatPeriod '2021-01-01', '2021-12-31', {now}

		it '7', -> deepEq ['week', 'Jul 6 - 12 2020'], q.formatPeriod '2020-07-06', '2020-07-12', {now}
		it 'custom', -> deepEq ['custom', 'May 3 - Jun 10'], q.formatPeriod '2021-05-03', '2021-06-10', {now}
		it 'custom same', -> deepEq ['custom', 'May 3 - 10'], q.formatPeriod '2021-05-03', '2021-05-10', {now}
		it 'custom same different years', -> deepEq ['custom', 'May 3 2020 - May 10 2021'], q.formatPeriod '2020-05-03', '2021-05-10', {now}
		it 'custom same day', -> deepEq ['custom', 'May 3'], q.formatPeriod '2021-05-03', '2021-05-03', {now}

		it '0', -> deepEq [null, 'Invalid period'], q.formatPeriod '2021-07-06', '2020-07-12', {now}
		it '8', -> deepEq [null, 'Invalid start date'], q.formatPeriod '2021-02-32', '2021-07-12', {now}
		it '9', -> deepEq [null, 'Invalid end date'], q.formatPeriod '2021-01-06', '2021-02-30', {now}

		it '11', -> deepEq ['quarter', 'Q2 2020'], q.formatPeriod '2020-04-01', '2020-06-30', {now}
		it '12', -> deepEq ['year', '2020'], q.formatPeriod '2020-01-01', '2020-12-31', {now}

		it 'month same long', -> deepEq ['month', 'January'], q.formatPeriod '2021-01-01', '2021-01-31', {now, long: true}
		it 'month long', -> deepEq ['month', 'January 2020'], q.formatPeriod '2020-01-01', '2020-01-31', {now, long: true}
		it 'week same long', -> deepEq ['week', 'May 3 - 9'], q.formatPeriod '2021-05-03', '2021-05-09', {now, long: true}
		it 'week long', -> deepEq ['week', 'April 26 - May 2'], q.formatPeriod '2021-04-26', '2021-05-02', {now, long: true}
		it 'quarter long', -> deepEq ['quarter', 'Q2 2021'], q.formatPeriod '2021-04-01', '2021-06-30', {now, long: true}
		it '7 long', -> deepEq ['week', 'July 6 - 12 2020'], q.formatPeriod '2020-07-06', '2020-07-12', {now, long: true}
		it '8 long', -> deepEq ['custom', 'April 3 - 10'], q.formatPeriod '2021-04-03', '2021-04-10', {now, long: true}
		it '11 long', -> deepEq ['quarter', 'Q2 2020'], q.formatPeriod '2020-04-01', '2020-06-30', {now, long: true}
		it '12 long', -> deepEq ['year', '2020'], q.formatPeriod '2020-01-01', '2020-12-31', {now, long: true}

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
		
	describe 'niceLines', () ->
		# simple
		it '0', () -> deepEq [2.5, 5.0, 7.5], q.niceLines 9
		it '1', () -> deepEq [10, 20, 30], q.niceLines 30
		it '2', () -> deepEq [15, 30, 45], q.niceLines 48
		it '3', () -> deepEq [25, 50, 75], q.niceLines 79
		it '4', () -> deepEq [50, 100, 150], q.niceLines 169
		it '5', () -> deepEq [75, 150, 225], q.niceLines 226
		it '6', () -> deepEq [100, 200, 300], q.niceLines 306

		# rounding up a bit
		it '0a', () -> deepEq [2.5, 5.0, 7.5], q.niceLines 7
		it '1a', () -> deepEq [10, 20, 30], q.niceLines 28
		it '2a', () -> deepEq [15, 30, 45], q.niceLines 43
		it '3a', () -> deepEq [25, 50, 75], q.niceLines 70
		it '4a', () -> deepEq [50, 100, 150], q.niceLines 145
		it '5a', () -> deepEq [75, 150, 225], q.niceLines 210
		it '6a', () -> deepEq [100, 200, 300], q.niceLines 270

	describe 'calcNicePeriod', () ->
		it 'wrong', () ->
			throws(/min bigger than max/, -> q.calcNicePeriod '2023-05-30', '2023-05-04')
		it '0', () -> eq 'm2023-05-01', q.calcNicePeriod '2023-05-01', '2023-05-30'
		it '1', () -> eq 'y2023-01-01', q.calcNicePeriod '2023-05-01', '2023-06-03'
		it '3', () -> eq 'total', q.calcNicePeriod '2022-05-01', '2023-06-03'
		# it '4', () -> eq '2023-03-05-2023-06-12', q.calcNicePeriod '2023-03-05', '2023-06-12'







