import type {GenericAsyncResult} from "./ns";

export declare type ScanType = "qrCode" | "barCode";
export declare type ParamScanCode = {
    scanType?: ScanType[];
    hideAlbum?: boolean;
};
export declare type ReturnScanCode = {
    scanType: ScanType;
    code: string;
};
declare module "./ns" {
    interface NSWebKit {
        /**
         * 扫码
         **/
        scanCode(param: ParamScanCode): Promise<GenericAsyncResult<ReturnScanCode>>;
    }
}