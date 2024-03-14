<script lang="ts" setup>
import Item from "../../components/Item.vue"
import {ref} from "vue";

window.ns?.setNavigationBarTheme({"hidden":false}).then((result)=>{
  console.log(result);
});
function openAppAuthorizeSetting(){
  window.ns?.openAppAuthorizeSetting().then((result)=>{
    console.log(result);
  });
}
function getAppInfoSync(){
  var result = window.ns?.getAppInfoSync();
  console.log(result);
  alert(JSON.stringify(result))
}
function setBadgeCount(param: any){
  window.ns?.setBadgeCount(param).then((result)=>{
    console.log(result);
  });
}
function navigateTo(param: any){
  window.ns?.navigateTo(param).then((result)=>{
    console.log(result);
  });
}
function navigateBack(){
  window.ns?.navigateBack().then((result)=>{
    console.log(result);
  });
}
function openExternalBrowser(param: any){
  window.ns?.openExternalBrowser(param).then((result)=>{
    console.log(result);
  });
}
function setNavigationBarTheme(param: any){
  window.ns?.setNavigationBarTheme(param).then((result)=>{
    console.log(result);
  });
}
function getDeviceInfoSync(){
  var result = window.ns?.getDeviceInfoSync();
  console.log(result);
  alert(JSON.stringify(result))
}
function getClipboardDataSync(){
  var result = window.ns?.getClipboardDataSync();
  console.log(result);
  alert(JSON.stringify(result))
}
function setClipboardData(param: any){
  window.ns?.setClipboardData(param).then((result)=>{
    console.log(result);
  });
}
function makePhoneCall(param: any){
  window.ns?.makePhoneCall(param).then((result)=>{
    console.log(result);
  });
}
function getNetworkType(){
  var result = window.ns?.getNetworkTypeSync();
  console.log(result);
  alert(JSON.stringify(result))
  window.ns?.onNetworkStatusChange((res) => {
    alert(JSON.stringify(res))
  })
}
function scanCode(param: any){
  window.ns?.scanCode(param).then((result)=>{
    console.log(result);
  });
}
function saveImageToPhotosAlbum(param: any){
  window.ns?.saveImageToPhotosAlbum(param).then((result)=>{
    console.log(result);
  });
}
function takePhoto() {
  window.ns?.chooseImage({sourceType: 'camera', count: 1}).then((result)=>{
    console.log(result);
  });
}
function chooseAlbum() {
  window.ns?.chooseImage({sourceType: 'album', count: 9}).then((result)=>{
    console.log(result);
  });
}
const imageUrl = ref('')
function uploadFile(event: any) {
  const file = event.target.files[0]
  console.log(file)
  if (file) {
    const reader = new FileReader();
    reader.onload = (e: any) => {
      imageUrl.value = e.target.result;
    };
    reader.readAsDataURL(file);
  }
}
function getLocation() {
  window.ns?.getLocationInfo().then((result)=>{
    console.log(result);
    alert(JSON.stringify(result))
  });
}
function chooseLocation() {
  window.ns?.chooseLocation({}).then((result)=>{
    console.log(result);
    alert(JSON.stringify(result))
  });
}
function encryptAndCalculateMac() {
  window.ns?.encryptAndCalculateMac({text: '123456'}).then((result)=>{
    console.log(result);
    alert(JSON.stringify(result))
  });
}
function openFile() {
  window.ns?.openFile({url: 'https://a2-linkwechat.oss-cn-shanghai.aliyuncs.com/mini-img/file/yssm-a2.docx'}).then((result)=>{
    console.log(result);
  });
}
const waterMark = ref('')
function addWaterMark() {
  window.ns?.addWaterMark({text: '我是一个图片水印', color: '#FFFFFF', fontSize: 100, imagePath: 'https://copyright.bdstatic.com/vcg/creative/cc9c744cf9f7c864889c563cbdeddce6.jpg'}).then((result)=>{
    console.log("addWaterMark", result.result?.path);
    waterMark.value = result.result?.path || ''
  });
}
function convertImagePathToBase64() {
  window.ns?.convertImagePathToBase64({path: 'https://copyright.bdstatic.com/vcg/creative/cc9c744cf9f7c864889c563cbdeddce6.jpg'}).then((result) => {
    console.log("convertImagePathToBase64", result);
  });
}
function setStorageSync() {
  console.log(window.ns?.setStorageSync('test','123456'))
}
function getStorageSync() {
  console.log(window.ns?.getStorageSync('test'))
}
function removeStorageSync() {
  console.log(window.ns?.removeStorageSync('test'))
}

</script>

<template>
<div class="index">
  <div class="title">Basic Plugin</div>
  <Item title="跳转当前App的系统授权管理⻚" @click="openAppAuthorizeSetting" />
  <Item title="获取当前App相关信息" @click="getAppInfoSync" />
  <Item title="设置APP角标" @click="setBadgeCount({count: 10})" />
  <Item title="打开新页面" @click="navigateTo({url: 'https://m.baidu.com'})" />
  <Item title="返回上一级" @click="navigateBack()" />
  <Item title="用外部浏览器打开⻚面" @click="openExternalBrowser({url: 'https://m.baidu.com'})" />
  <Item title="显示导航栏" @click="setNavigationBarTheme({hidden: false})" />
  <Item title="隐藏导航栏" @click="setNavigationBarTheme({hidden: true})" />
  <Item title="设置标题文字" @click="setNavigationBarTheme({title: '自定义标题'})" />
  <Item title="设置导航栏颜色" @click="setNavigationBarTheme({color: '#EEEEEE'})" />
  <Item title="设置导航栏颜色2" @click="setNavigationBarTheme({color: '#EAAAAA'})" />
  <Item title="设置标题文字颜色" @click="setNavigationBarTheme({titleColor: '#FFD700'})" />
  <Item title="设置导航右侧按钮文字" @click="setNavigationBarTheme({actionTxt: '按钮'})" />
  <Item title="获取设备相关信息" @click="getDeviceInfoSync()" />
  <Item title="获取系统剪贴板的内容" @click="getClipboardDataSync()" />
  <Item title="设置系统剪贴板的内容" @click="setClipboardData({data: '新设置的内容'})" />
  <Item title="拨打电话" @click="makePhoneCall({phoneNumber: '10000'})" />
  <Item title="获取设备网络状态" @click="getNetworkType()" />
  <Item title="打开文件" @click="openFile()" />
  <Item title="添加水印" @click="addWaterMark()" custom>
    <img v-if="waterMark" style="width: 100%; height: auto" :src="waterMark" />
  </Item>
  <Item title="图片转base64" @click="convertImagePathToBase64()" />
  <Item title="本地数据存储（同步）" @click="setStorageSync()" />
  <Item title="本地数据读取（同步）" @click="getStorageSync()" />
  <Item title="本地数据删除（同步）" @click="removeStorageSync()" />

  <div class="title">Scan Plugin</div>
  <Item title="扫码" @click="scanCode({scanType: ['qrCode']})" />

  <div class="title">CustomCamera Plugin</div>
  <Item title="拍照" @click="takePhoto()" />
  <Item title="相册" @click="chooseAlbum()" />
  <Item title="保存到相册" @click="saveImageToPhotosAlbum({base64Image: 'data:image/png;base64,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'})" />

  <div class="title">Camera Plugin (Android)</div>
  <Item custom>
    <input id="input1" type="file" accept="image/*" style="display: none" @change="uploadFile">
    <input id="input2" type="file" accept="image/*" capture="camera" @change="uploadFile" style="display: none">
    <input id="input3" type="file" accept="video/*" capture="camcorder" @change="uploadFile" style="display: none">
    <div class="custom">
      <label for="input1">拉起相册：</label>
      <label for="input2">拉起相机：</label>
      <label for="input3">拉起摄像头：</label>
    </div>
    <img class="custom-img" :src="imageUrl" id="v_photoA">
  </Item>

  <div class="title">Location Plugin</div>
  <Item title="定位" @click="getLocation()" />
  <Item title="地图点选" @click="chooseLocation()" />

  <div class="title">Custom Plugin</div>
  <Item title="加密" @click="encryptAndCalculateMac()" />
</div>
</template>

<style lang="scss" scoped>
.index {
  padding: 10px 15px;

  .title {
    text-align: left;
    margin: 10px auto;
    position: relative;
    padding-left: 10px;
  }

  .custom {
    display: flex;
    label {
      flex: 1;
      border-radius: 10px;
      font-size: 13px;
      color: #333;
      padding: 10px 0;
      background: aliceblue;
      /*text-decoration: underline;*/
      /*text-underline: blue;*/
      text-align: center;
    }

    label + label {
      margin-left: 10px;
    }

    input {
      display: none;
    }
  }

  .custom-img {
    margin-top: 10px;
    width: 100%;
    height: auto;
  }
}
</style>