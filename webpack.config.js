import path from 'path'
import {fileURLToPath} from 'url'
import glob from 'glob'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

const testEntries = glob.sync("./{client,server,shared}/**/test__*.coffee").reduce((acc, val) => {
			const filenameRegex = /test__([\w\d_-]*)\.coffee$/i
			acc[val.match(filenameRegex)[1]] = val
			return acc
		}, {})

const config = {
	entry: testEntries,
	mode: 'development',

	devtool: 'inline-cheap-module-source-map',
	// devtool: 'cheap-module-source-map',

	output: {
		filename: '[name].test.js',
		path: path.resolve(__dirname, 'temp'),
		clean: true,
	},
	module: {
		rules: [
			{
				include: [
					path.resolve(__dirname),
					path.resolve(__dirname, '../ramda-extras'),
					path.resolve(__dirname, '../popsiq'),
				],
				exclude: /node_modules|packages/,
				test: /\.coffee$/,
				use: [
					{loader: 'coffee-loader'},
					{loader: path.resolve(__dirname, '../hack/loaders/keywordCoffeeLoader.js')},
				]
			},
		],
	},
	target: 'node',
	resolve: {
		extensions: ['.js', '.coffee'],
		alias: {
			'ramda-extras': path.resolve(__dirname, '../ramda-extras'),
			popsiql: path.resolve(__dirname, '../popsiql/src/index')
		}
	},
}

export default config
