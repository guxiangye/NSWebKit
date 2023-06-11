import {GenericAsyncResult} from "./ns";

export type ScanType = "qrCode" | "barCode";
export type ParamScanCode = {
    scanType?: ScanType[];
    hideAlbum?: boolean;
};
export type ReturnScanCode = {
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