import { createRouter, createWebHashHistory, RouteRecordRaw } from "vue-router"
const history = createWebHashHistory()

const routes: Array<RouteRecordRaw> = [
    {
        path: "/",
        redirect: "/index",
    },
    {
        path: "/index",
        name: "index",
        component: () => import("../views/index/index.vue")
    },
    {
        path: "/other",
        name: "other",
        component: () => import("../views/other/index.vue")
    }
]

const router = createRouter({
    history,
    routes
})

/**
 * 导出默认的路由
 */
export default router