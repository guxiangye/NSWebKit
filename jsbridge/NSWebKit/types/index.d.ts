export * from "./plugins/ns";
export * from "./plugins/ns.basic";
export * from "./plugins/ns.customCamera";
export * from "./plugins/ns.scan";
export * from "./plugins/ns.location";
export * from "./plugins/ns.share";
export * from "./plugins/ns.encrypt";
import { NSWebKit } from "./plugins/ns";
declare global {
    const ns: NSWebKit;
    interface Window {
        ns: NSWebKit;
    }
}
