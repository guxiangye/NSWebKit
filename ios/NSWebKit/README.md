# SDPCordovaLib

[![CI Status](https://img.shields.io/travis/高鹏程/SDPCordovaLib.svg?style=flat)](https://travis-ci.org/高鹏程/SDPCordovaLib)
[![Version](https://img.shields.io/cocoapods/v/SDPCordovaLib.svg?style=flat)](https://cocoapods.org/pods/SDPCordovaLib)
[![License](https://img.shields.io/cocoapods/l/SDPCordovaLib.svg?style=flat)](https://cocoapods.org/pods/SDPCordovaLib)
[![Platform](https://img.shields.io/cocoapods/p/SDPCordovaLib.svg?style=flat)](https://cocoapods.org/pods/SDPCordovaLib)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SDPCordovaLib is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDPCordovaLib'
```

## Author

高鹏程, gaopengcheng@shengpay.com

## Modify
谷相晔, guxiangye@shengpay.com

## License

SDPCordovaLib is available under the MIT license. See the LICENSE file for more info.

## 关于容器化APP Cordova 封装JS 脚本 ns.ts 自动生成 ns.js 和 ns.d.ts
在终端 打开 NS 文件夹 , 输入 tsc 就可以自动生成.

## 引用
```ruby
pod 'SDPCordovaLib/MPOSLib', :git => 'git@sdpgitlab.shengpayqa.com:mobile_iOS/SDPCordovaLib.git', :tag => '1.0.9.7'
```

## 添加预编译定义宏 
### 环境变量
```ruby
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        if target.name == 'SDPCordovaLib'
          target.build_configurations.each do |config|
              if config.name == 'AppStoreDebug'
                  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [ '$(inherited)', 'DEBUG=1', 'ISTEST=1' ]
              end
              if config.name == 'TestDistribute'
                  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [ '$(inherited)', 'PRE_PROD=1' ]
              end
              if config.name == 'AppStoreRelease'
                  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [ '$(inherited)', 'RELEASE=1' ]
              end
          end
        end

    end
end
```

## 1.0.7 
支持调整客服链接

## 1.0.8
统一cordova 回调数据格式

## 1.0.9
应用安全优化: MD5 -> SHA256
拍照失真问题调试优化

## 1.0.9.2
非强制更新，alert 提示窗放开

## 1.0.9.3
选拍照后选相册问题

## 1.0.9.4
定位文案描述不完整，导致审核失败问题优化

## 1.0.9.5
定位逻辑优化

## 1.0.9.6
优化子webview KVC 释放问题

## 1.0.9.7
支持动态配置 RSA 秘钥

## 1.0.9.8
SHANGHU-7299 支持动态配置 H5 全路径，适配拓展员

## 1.0.9.9
动态 RSA 秘钥 /n转义问题优化

## 1.1.0.1
config.xml 调整，去掉allow-navigation *，适配iOS15 导航头；
RSA 默认秘钥判空逻辑优化


## 1.1.0.2
SHANGHU-7299 适配拓展员，动态控制引导页图片数据，动态显示分页器

## 1.1.0.3
SHANGHU-7299 优化 userAgent 动态刷新 checkVersion 字段

## 1.1.0.4
修复1.1.0.3 闪屏问题优化

## 1.1.1
SHANGHU-7759 iOS APP 需同意隐私协议

## 1.1.2.1
SHANGHU-8026 iOS APP 更换图片压缩算法

## 1.1.4
SHANGHU-9470 iOS 更换高德地图SDK


## 1.1.9
容器化 webview 增加清除缓存功能
## 1.2.0
容器化 webview 增加定位插件
