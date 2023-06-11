export type GenericAsyncResult<T = any> = {
    errCode: number;
    errorMsg?: string;
    result?: T;
};

export interface NSWebKit {}

declare global {
    const ns: NSWebKit;
    interface Window {
        ns: NSWebKit;
    }
}