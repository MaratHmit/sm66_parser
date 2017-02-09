var webpack = require('webpack')
var HtmlWebpackPlugin = require('html-webpack-plugin')
var env = 'production'
var config = require('./webpack.config.js')

config.plugins = [ 
        new webpack.ContextReplacementPlugin(/node_modules\/moment\/locale/, /(ru|en-gb)/),
        new webpack.ProvidePlugin({
            riot: 'riot',
			$: 'jquery',
            jQuery: 'jquery',
            observable: 'scripts/sharedObservable.js',
            app: 'app.js',
            API: 'scripts/api.js'
        }),
        new HtmlWebpackPlugin({
            inject: false,
            template: './index.pug'
        }),
        new webpack.DefinePlugin({
          'process.env.NODE_ENV': JSON.stringify(env)
        })
]

config.debug = false
config.devtool = 'source-map'
delete config.devServer

module.exports = config
