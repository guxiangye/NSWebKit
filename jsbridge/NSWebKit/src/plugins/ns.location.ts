import type {GenericAsyncResult} from "./ns";

export declare type ReturnLocationInfo = {
    formattedAddress?: string;
    country?: string;
    province?: string;
    city?: string;
    district?: string;
    street?: string;
    latitude: number;
    longitude: number;
};

export declare type ParamChooseLocation = {
    /**
     * 查询POI类型 详见:https://lbs.amap.com/api/webservice/guide/api/search
     * 此值不传 默认为: 050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|160000|170000
     **/
    types?: string;
};

export declare type ReturnChooseLocationInfo = {
    address?: string;
    name?: string;
    province?: string;
    city?: string;
    district?: string;
    businessArea?: string;
    latitude: number;
    longitude: number;
};

declare module "./ns" {
    interface NSWebKit {
        /**
         * 获取定位
         **/
        getLocationInfo(): Promise<GenericAsyncResult<ReturnLocationInfo>>;
        /**
         * 地图选点
         **/
        chooseLocation(param: ParamChooseLocation): Promise<GenericAsyncResult<ReturnChooseLocationInfo>>;
    }
}