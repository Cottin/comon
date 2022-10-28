import has from "ramda/es/has"; import includes from "ramda/es/includes"; import isNil from "ramda/es/isNil"; import join from "ramda/es/join"; import map from "ramda/es/map"; import min from "ramda/es/min"; import none from "ramda/es/none"; import reject from "ramda/es/reject"; import remove from "ramda/es/remove"; import reverse from "ramda/es/reverse"; import split from "ramda/es/split"; import splitEvery from "ramda/es/splitEvery"; import test from "ramda/es/test"; import type from "ramda/es/type"; #auto_require: esramda
import {change, $, isNilOrEmpty} from "ramda-extras" #auto_require: esramda-extras

import React from 'react'
import {RendererProvider} from 'react-fela'
import {createRenderer} from 'fela'
import webPreset from 'fela-preset-web'
import shortstyle from 'shortstyle'


export default styleSetup = ({families, bg, styleMaps, colors, staticBefore = '', staticAfter}) ->

	felaRenderer = createRenderer {plugins: [...webPreset]}

	felaRenderer.renderStatic """
	#{staticBefore}

	html, body {
		display: flex;
		flex-direction: column;
		flex-grow: 1;
		margin: 0;
		padding: 0;
		font-family: #{families[0]};
	}

	html {
		font-size: calc(8px + 0.15vw);
		background-color: #{bg};
	}


	@media screen and (min-width: 1300px) {
		html {
			font-size: 10px;
		}
	}

	* {
		box-sizing: border-box;
	}


	/* RESETS */
	/* https://meyerweb.com/eric/tools/css/reset/ */
	h1, h2, h3, h4, h5, h6, p, blockquote, pre, a {
		margin: 0;
		padding: 0;
		border: 0;
		font-size: 100%;
		font: inherit;
		vertical-align: baseline;
	}

	a {
		color: inherit;
		text-decoration: none;
	}

	textarea,
	input.text,
	input[type="text"],
	input[type="email"],
	input[type="password"],
	input[type="button"],
	input[type="submit"] {
		/* https://www.daretothink.co.uk/stop-ios-styling-your-input-fields-and-buttons/ */
		/* https://stackoverflow.com/a/15440636/416797 */
		-webkit-appearance: none;
		/*border-radius: 0; This messes with br8_8_8_8, disabling for now*/
		/* margin: 0; This messes up with m10 on inputs, disabling for now /* seems iOS (eg. iPhone 8) adds some margin */
		/*background: none;*/
		/*border: none;*/
		font-family: #{families[0]};
	}

	button {
		/* https://www.daretothink.co.uk/stop-ios-styling-your-input-fields-and-buttons/ */
		/* https://stackoverflow.com/a/15440636/416797 */
		-webkit-appearance: none;
		/*border-radius: 0; This messes with br8_8_8_8, disabling for now*/
		/* margin: 0; This messes up with m10 on inputs, disabling for now /* seems iOS (eg. iPhone 8) adds some margin */
		/*background: none;*/
		/*border: none;*/
		font-family: #{families[0]};
	}

	/* The above reset has too high specificity with [type="text, password..."] so that m10 or br8 is not applied.not
			Because of that doing a less specific reset here. Does this interfere with something else? */
	textarea,
	input {
		margin: 0;
		border-radius: 0;
	}

	textarea:focus, input:focus {
		outline: none;
	}

	textarea {
		border: none;
		overflow: auto;
		outline: none;

		-webkit-box-shadow: none;
		-moz-box-shadow: none;
		box-shadow: none;

		resize: none; /*remove the resize handle on the bottom right*/
	}

	button {
		border: none;
	}

	#{staticAfter}

	"""

	fallbackRenderer = felaRenderer

	# class FelaProvider extends Component
	FelaProvider = ({renderer, children}) ->	
		renderer = renderer || fallbackRenderer
		return React.createElement RendererProvider, {renderer},
				children



	parseShortstyle = shortstyle {styleMaps, colors, families}

	if typeof window != 'undefined' then window.test123 = {}

	createElementFela = ->
		[a0] = arguments


		isComp = false
		compName = null
		if 'Object' == type(a0) && ! has '$$typeof', a0
			comp = 'div'
			Props = a0
			children = Array.prototype.splice.call(arguments, 1)
		else
			comp = a0 # either a string or a component, eg. 'span' or Icon
			compName = a0.name
			# if type(comp) != 'String' && !test(/Svg/, comp.name) && comp.name != '' then isComp = true
			if type(comp) != 'String' && !test(/Svg/, comp.name) then isComp = true
			if comp.$$noComp then isComp = false
			Props = arguments[1]
			children = Array.prototype.splice.call(arguments, 2)

		if isComp
			props_ = $ Props, change {s: (s) -> "#{s||''},#{a0.name},"}
		else
			extras = {}
			s = Props.s
			if Props.s && includes ',', Props.s
				sNamePairs = $ Props.s, split(','), splitEvery(2)
				sLiteral = $ sNamePairs, map(([s, name]) -> "#{s}, #{name}"), join(' > ')
				totalName = $ sNamePairs, map(([s, name]) -> name), reject(isNil), join('>')
				s = $ sNamePairs, map(([s, name]) -> s), reject(isNilOrEmpty), reverse, join(' ')
				sLiteral = $ sNamePairs, map(([s, name]) -> s), reject(isNilOrEmpty), reverse, join(' > ')
				extras = {s: totalName + ' :: ' + sLiteral}

			felaStyle = parseShortstyle s
			felaClassName = felaRenderer.renderRule (-> felaStyle), {}

			props_ = $ Props, change {
				className: (c) -> $ [c, felaClassName], reject(isNilOrEmpty), join(' '), (x) -> x || undefined
				...extras
			}

			if typeof window != 'undefined' then window.test123[comp.name] = comp


		# console.log 'typof', comp.$$typeof
		# console.log 'props_', props_, 'props', props, 'felaClassName', felaClassName, 'felaStyle', felaStyle, 's', s, {comp}

		return React.createElement comp, props_, children...

	array = (xs...) -> xs

	# Underscore is such a nice alias helper so we're doing some guessing to determin if it
	# was used for array (popsiql queries / data queries) or for react.createElement.
	arrayOrRenderer = ->
		[a0, a1] = arguments

		if arguments.length == 1
			# This case is hard... For now you cannot render _ {} you must have _ {is: ''} or _ {s: ''}
			if 'Object' == type(a0) && (has('s', a0) || has('is', a0) || has('style', a0)) then createElementFela arguments...
			else return array arguments...

		if 'Object' == type a0
			# if React.isValidElement a1
			# 	console.log a1
			# return createElementFela arguments...
			if isNil a1 then return createElementFela arguments...
			else if has '$$typeof', a0 then return createElementFela arguments... # ex. React.memo
			else if 'Object' == type(a1)
				if has '$$typeof', a1 then return createElementFela arguments...
				else return array arguments...
			# else if 'Array' == type a1 then return createElementFela arguments...
			# else if 'String' == type a1 then return createElementFela arguments...
			else
				return createElementFela arguments...
			# if React.isValidElement a1 then return createElementFela arguments...
			# else return array arguments...
			# console.log a1
			# return createElementFela arguments...
			# if 'Object' == type a1 then return array arguments...
			# else return createElementFela arguments...

		else if 'Function' == type(a0) || 'String' == type(a0)
			if 'Object' == type a1 then return createElementFela arguments...
		else if 'Symbol' == type(a0) && a0.toString() == 'Symbol(react.fragment)'
			return React.createElement arguments...

		else if isNil a0
			console.error "arrayOrRenderer got nil as first argument", Array.from(arguments)
			throw new Error "arrayOrRenderer got nil as first argument, see console for full arguments"

		return array arguments...


	arrayOrRenderer.colors = colors

	return {felaRenderer, FelaProvider, createElementFela, arrayOrRenderer}


