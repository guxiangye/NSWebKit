const TerserPlugin = require("terser-webpack-plugin");
console.log("com.nswebkit.build.ts", "start.")

module.exports = {
    mode: 'none',
    entry: {
        [`ns`]: './src/index.ts',
        [`ns.min`]: './src/index.ts'
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
                test: /\.tsx?$/,
                use: "ts-loader",
                exclude: /node_modules/
            }
        ]
    },
    resolve: {
        extensions: [".ts"] // 解析对文件格式
    }
}
