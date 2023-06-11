import {GenericAsyncResult} from "./ns";

export type ReturnLocationInfo = {
    formattedAddress?: string;
    country?: string;
    province?: string;
    city?: string;
    district?: string;
    street?: string;
    latitude: number;
    longitude: number;
};

declare module "./ns" {
    interface NSWebKit {
        /**
         * 获取定位
         **/
        getLocationInfo(): Promise<GenericAsyncResult<ReturnLocationInfo>>;
    }
}