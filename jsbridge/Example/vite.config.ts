import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  base: "./",
  plugins: [vue()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  build: {
    // 最终构建的浏览器兼容目标，类型：string | string[]
    target: '',
    //指定输出路径
    outDir: "www",
    //生成静态资源的存放的路径
    assetsDir: "assets",
    // 设置资源阈值，小于该值将内联为 base64 编码，避免额外的 http 请求
    assetsInlineLimit: 4096,
    //启用/禁用 CSS 代码拆分，如果有设置build.lib，build.cssCodeSplit 会默认为 false，
    //false 的话会将项目中的所以 css 提取到一个 css 文件中
    cssCodeSplit: true,
    // 构建后是否生成 source map 文件, boolean | 'inline' | 'hidden'
    sourcemap: false,
    // //自定义底层的 Rollup 打包配置
    rollupOptions: {
      // 可以配置多个，表示多入口
      input: {
        index: resolve(__dirname, "index.html")
      },
      output: {
        chunkFileNames: 'static/js/[name]-[hash].js',
        entryFileNames: "static/js/[name]-[hash].js",
        assetFileNames: "static/[ext]/name-[hash].[ext]"
      }
    },
    // 禁用将构建后的文件写入磁盘
    // write: false,
    // //默认情况下，若 outDir 在 root 目录下，则 Vite 会在构建时清空该目录。
    // emptyOutDir: true,
    //chunk 大小警告的限制
    chunkSizeWarningLimit: 4000
  },
  server: {
    host: '0.0.0.0'
  }
})
