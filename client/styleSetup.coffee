 #auto_require: _esramda
import {} from "ramda-extras" #auto_require: esramda-extras

import React, {useContext} from 'react'
import {RendererProvider, RendererContext} from 'react-fela'
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

	useFela = () ->
		renderer = useContext RendererContext
		return (s) ->
			return renderer.renderRule (-> parseShortstyle s), {}


	parseShortstyle = shortstyle {styleMaps, colors, families}


	return {felaRenderer, FelaProvider, useFela}


