import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns"
import {
    ParamCompressImage,
    ParamImageToPhotosAlbum,
    ParamChooseImage
} from "../plugins/ns.customCamera";

export const customCamera:NSWebKit = <NSWebKit>{
    async compressImage(param: ParamCompressImage) {
        return await core.cordovaExec("NSCustomCameraPlugin", "compressImage", [param]);
    },

    async saveImageToPhotosAlbum(param: ParamImageToPhotosAlbum) {
        return await core.cordovaExec("NSCustomCameraPlugin", "saveImageToPhotosAlbum", [param]);
    },

    async chooseImage(param: ParamChooseImage) {
        return await core.cordovaExec("NSCustomCameraPlugin", "chooseImage", [param]);
    }
}