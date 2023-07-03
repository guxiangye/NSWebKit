import { core } from "../plugins/ns.core";
declare const core: core;
export declare const jsPrivateObj: {
    handleMessageFromNative(messageJSON: string): void;
    noticeUserLogin(messageJSON: string): void;
    noticeUserLogout(): void;
    noticePageShow(): void;
    noticePageHide(): void;
    toast(param: {
        msg: string;
    }): Promise<any>;
};
export default core;
