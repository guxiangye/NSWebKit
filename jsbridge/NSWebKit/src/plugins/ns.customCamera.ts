import type {GenericAsyncResult} from "./ns";

export declare type ParamImageToPhotosAlbum = {
    base64Image: string;
};
export declare type ParamCompressImage = {
    base64Image: string;
    maxLength?: number;
};
export declare type ReturnCompressImageResult = {
    base64Image: string;
};
export declare type ChooseImageSizeType = "original" | "compressed";
export declare type ChooseImageSourceType = "album" | "camera";
export declare type ParamChooseImage = {
    sourceType: ChooseImageSourceType;
    sizeType?: ChooseImageSizeType[];
    count?: number;
};
export declare type ReturnImageDataResult = {
    original: string;
    originalBase64: string;
    compressed: string;
    compressBase64: string;
};
export declare type ReturnChooseImageResult = {
    data: ReturnImageDataResult[];
};
declare module "./ns" {
    interface NSWebKit {
        /**
         * 压缩图片
         **/
        compressImage(param: ParamCompressImage): Promise<GenericAsyncResult<ReturnCompressImageResult>>;
        /**
         * 保存图片到相册
         **/
        saveImageToPhotosAlbum(param: ParamImageToPhotosAlbum): Promise<GenericAsyncResult<undefined>>;

        /**
         * 选择照片
         **/
        chooseImage(param: ParamChooseImage): Promise<GenericAsyncResult<ReturnChooseImageResult>>;
    }
}