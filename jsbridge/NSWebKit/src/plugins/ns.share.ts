import type {GenericAsyncResult} from "./ns";

export declare type WXShareType = "WXSceneSession" | "WXSceneTimeline" | "WXSceneFavorite";
export declare type ParamShareToWX = {
    webpageUrl: string;
    title: string;
    description: string;
    thumbImage: string;
    scene: WXShareType;
};
export declare type MiniProgramType = "WXMiniProgramTypeRelease" | "WXMiniProgramTypeTest" | "WXMiniProgramTypePreview";
export declare type ReturnWXAuthResult = {
    code: string;
};
export declare type ParamShareToWXMiniProgram = {
    title: string;
    description: string;
    webpageUrl: string;
    userName: string;
    path: string;
    hdImageData: string;
    withShareTicket: boolean;
    miniProgramType: MiniProgramType;
};
export declare type ReturnOpenWXMiniProgramResult = {
    extMsg: string;
};
export declare type ParamOpenWXMiniProgram = {
    userName: string;
    path: string;
    miniProgramType: MiniProgramType;
};
declare module "./ns" {
    interface NSWebKit {
        /**
         * 微信授权,并返回用户信息
         **/
        sendWXAuthRequest(): Promise<GenericAsyncResult<ReturnWXAuthResult>>;
        /**
         * 微信分享
         **/
        shareToWX(param: ParamShareToWX): Promise<GenericAsyncResult<undefined>>;
        /**
         * 打开微信小程序
         **/
        launchWXMiniProgram(param: ParamOpenWXMiniProgram): Promise<GenericAsyncResult<ReturnOpenWXMiniProgramResult>>;
        /**
         * 微信分享小程序
         **/
        shareToWXMiniProgram(param: ParamShareToWXMiniProgram): Promise<GenericAsyncResult<undefined>>;
    }
}