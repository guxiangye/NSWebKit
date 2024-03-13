export declare type ReturnEncryptData = {
    data: any;
};
declare module "./ns" {
    interface NSWebKit {
        /**
         * 加密和加签
         **/
        encryptAndCalculateMac(param: any): Promise<GenericAsyncResult<ReturnEncryptData>>;
    }
}
