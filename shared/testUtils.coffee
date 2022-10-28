import assert from 'assert'
import glob from 'glob'

export deepEq = (a, b, c) ->
	assert.deepStrictEqual(b, a, c)
deepEq.log = (a, b, c) ->
	console.log b
	assert.deepStrictEqual(b, a, c)

export fdeepEq = (a, b, c) ->
	assert.deepStrictEqual(a, b, c)
fdeepEq.log = (a, b, c) ->
	console.log a
	assert.deepStrictEqual(a, b, c)

export eq = (a, b, c) ->
	assert.strictEqual(b, a, c)
eq.log = (a, b, c) ->
	console.log b
	assert.strictEqual(b, a, c)

export feq = (a, b, c) ->
	assert.strictEqual(b, a, c)
feq.log = (a, b, c) ->
	console.log 
	assert.strictEqual(a, b, c)

export throws = (re, f) -> assert.throws f, re
throws.log = (re, f) ->
	console.log f()
	assert.throws f, re


# Use to wrap await calls in test files so errors are not hidden
# eg. res = await defuse pgPopsiql.sql query1
# https://github.com/facebook/jest/issues/6028#issuecomment-567669082
export defuse = (promise) ->
	promise.catch (err) -> console.error err
	return promise
