var webpack = require("webpack");
var HtmlWebpackPlugin = require('html-webpack-plugin');
var path = require('path');

var precss = require('precss')
var autoprefixer = require('autoprefixer')
var csswring = require('csswring')

var env = 'development'

module.exports = {
    context: path.resolve('src'),
    entry: {
        app: './index.js',
    },
    output: {
        path: './build',
        filename: 'bundle.js'
    },
    devtool: '#source-map',
    debug: true,
    plugins: [
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
    ],
    resolve: {
        root: path.resolve('src')
    },
    module: {
        preLoaders: [
            { test: /\.tag$/, exclude: /node_modules/, loader: 'riotjs', query: {type: 'none', template: 'pug', compact: true, whitespace: true}}
        ],
        loaders: [
            { test: /\.jade|\.pug$/, loader: 'pug-html' },
            { test: /\.js|\.tag$/, exclude: /node_modules/, include: /src/, loader: 'babel'},
            { test: /\.css$/, exclude: /src/, loader: 'style!css' },
            { test: /\.css$/, include: /src/, loader: 'style!css!postcss' },
            { test: /\.eot(\?v=\d+\.\d+\.\d+)?$/, loader: "file?&name=files/[hash].[ext]" },
            { test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/, loader:"url?limit=10000&mimetype=application/font-woff&name=files/[hash].[ext]" },
            { test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/, loader: "url?limit=10000&mimetype=application/octet-stream&name=files/[hash].[ext]" },
            { test: /\.svg(\?v=\d+\.\d+\.\d+)?$/, loader: "url?limit=10000&mimetype=image/svg+xml&name=files/[hash].[ext]" },
            { test: /\.png$/i, loader: "file?name=files/[hash].[ext]!image-webpack" },
            { test: /\.jpe?g$/i, loader: "file?&name=files/[hash].[ext]!image-webpack" }
        ],
    },
    noParse: /node_modules\/(jquery|bootstrap)/,
    postcss: [precss, autoprefixer, csswring],
    devServer: {
        contentBase: './build/',
        host: '0.0.0.0',
        port: 1338,
        hot: true,
        inline: true
    }
};