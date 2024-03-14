export * from "./rollup/ns.example";
import { NSWebKit } from "./rollup/ns.example";
declare global {
    const ns: NSWebKit;
    interface Window {
        ns: NSWebKit;
    }
}