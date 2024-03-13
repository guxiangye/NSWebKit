const TerserPlugin = require("terser-webpack-plugin");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
console.log("com.nswebkit.build.ts", "start.")

module.exports = {
    mode: 'production',
    entry: {
        [`ns`]: './src/impl/ns.impl.ts',
        [`ns.min`]: './src/impl/ns.impl.ts'
    },
    output: {
        path: __dirname + '/dist',
        // 输出文件名称
        filename: `[name].js`
    },
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin({
                include: /\.min\.js$/
            })
        ]
    },
    module: {
        rules: [
            {
                test: /\.(js|ts)$/,
                // use: "ts-loader",
                loader: "babel-loader",
                exclude: /node_modules/
            }
        ]
    },
    resolve: {
        extensions: [".js", ".ts", ".json"] // 解析对文件格式
    },
    plugins: [
        new CleanWebpackPlugin()
    ]
}
