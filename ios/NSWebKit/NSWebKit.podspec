#
# Be sure to run `pod lib lint NSWebKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    #  These will help people to find your library, and whilst it
    #  can feel like a chore to fill in it's definitely to your advantage. The
    #  summary should be tweet-length, and the description more in depth.
    #
    s.name             = 'NSWebKit'
    s.version          = '1.0.0'
    s.summary          = 'A short description of NSWebKit.'
    s.static_framework = true
    s.homepage         = "https://github.com/guxiangye/NSWebKit"
    
    # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    
    # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    s.author           = { "neil" => "guxiangyee@163.com" }
    
    # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    #  Specify the location from where the source should be retrieved.
    #  Supports git, hg, bzr, svn and HTTP.
    #
    s.source           = { :git => "https://github.com/guxiangye/NSWebKit.git", :tag => s.version.to_s }
    
    # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    #  If this Pod runs only on iOS or OS X, then specify the platform and
    #  the deployment target. You can optionally include the target after the platform.
    #
    s.ios.deployment_target = '9.0'
    
    # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #
    #  CocoaPods is smart about how it includes source code. For source files
    #  giving a folder will include any swift, h, m, mm, c & cpp files.
    #  For header files it will include any header in the folder.
    #  Not including the public_header_files will make all headers public.
    #
    s.default_subspecs = 'Core'
    
    s.subspec 'Cordova' do |sp|
        sp.source_files = 'Cordova/*.{h,m}'
        sp.xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => 'WK_WEB_VIEW_ONLY=1' }
    end

    s.subspec 'Core' do |sp|
        sp.dependency 'NSWebKit/Cordova'
        sp.dependency 'Masonry', '~>1.1.0'
        sp.dependency 'YYKit', '~> 1.0.9'
        sp.dependency 'Toast', '~> 4.0.0'
        
        sp.subspec 'Classes' do |ss|
            ss.source_files = 'Core/Classes/**/*.{h,m}'
        end
        sp.subspec 'Assets' do |ss|
            ss.resources = ['Core/Assets/*']
        end
    end
    
    s.subspec 'Plugins' do |sp|
        sp.dependency 'NSWebKit/Core'

        sp.subspec 'Basic' do |ss|
            ss.source_files = 'Plugins/Basic/*.{h,m}'
            ss.dependency 'LBXPermission/Base'
        end
        
        sp.subspec 'CustomCamera' do |ss|
            ss.source_files = 'Plugins/CustomCamera/*.{h,m}'
            ss.dependency 'LBXPermission/Base'
            ss.dependency 'LBXPermission/Camera'
            ss.dependency 'LBXPermission/Photo'
            ss.dependency 'TZImagePickerController'
            ss.dependency 'ZYImageCompress'
        end
        
        sp.subspec 'Scan' do |ss|
            ss.source_files = 'Plugins/Scan/*.{h,m}'
            ss.dependency 'LBXPermission/Base'
            ss.dependency 'LBXPermission/Camera'
            ss.dependency 'LBXPermission/Photo'
            ss.dependency 'LBXScan/LBXNative'
            ss.dependency 'LBXScan/UI'
            ss.xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => 'LBXScan_Define_UI=1' }
            ss.subspec 'Assets' do |sss|
                sss.resources = ['Plugins/Scan/Assets/*']
            end
        end
        
        sp.subspec 'Location' do |ss|
             ss.source_files = 'Plugins/Location/*.{h,m}'
             ss.dependency 'NSWebKit/Plugins/Basic'
             ss.dependency 'LBXPermission/Location'
             ss.dependency 'AMapLocation-NO-IDFA', '~> 2.9.0'
        end
        
        sp.subspec 'ChooseLocation' do |ss|
          ss.source_files = 'Plugins/ChooseLocation/*.{h,m}'
             ss.dependency 'NSWebKit/Plugins/Basic'
             ss.dependency 'LBXPermission/Location'
             ss.dependency 'MJRefresh', '~> 3.7.5'
             ss.dependency 'AMap3DMap-NO-IDFA', '~> 9.7.0'
             ss.dependency 'AMapSearch-NO-IDFA', '~> 9.7.0'
             ss.subspec 'Assets' do |sss|
                 sss.resources = ['Plugins/ChooseLocation/Assets/*']
             end
        end
        
        sp.subspec 'Share' do |ss|
            ss.source_files = 'Plugins/Share/*.{h,m}'
            ss.dependency 'NSWebKit/Plugins/Basic'
            ss.dependency 'WechatOpenSDK', '~> 1.8.7.1'
        end
    end
end
