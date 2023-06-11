import {GenericAsyncResult} from "./ns";

export type ParamImageToPhotosAlbum = {
    base64Image: string;
};
export type ParamCompressImage = {
    base64Image: string;
    maxLength?: number;
};
export type ReturnCompressImageResult = {
    base64Image: string;
};
export type ChooseImageSizeType = "original" | "compressed";
export type ChooseImageSourceType = "album" | "camera";
export type ParamChooseImage = {
    sourceType: ChooseImageSourceType;
    sizeType?: ChooseImageSizeType[];
    count?: number;
};
export type ReturnImageDataResult = {
    original: string;
    originalBase64: string;
    compressed: string;
    compressBase64: string;
};
export type ReturnChooseImageResult = {
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