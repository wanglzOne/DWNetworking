Pod::Spec.new do |s|

  s.name         = "DWNetworking"
  s.version      = "0.0.1"
  s.summary      = "基于AFNetworking～3.1.0 & YYCache~1.0.4"
  s.description  = <<-DESC
  - 基于```AFNetworking~>3.1.0``` & ```YYCache~>1.0.4```
  - ```轻量级``` & ```可定制```
  - 最低支持版本```iOS 8.0```
  - 交流群```577506623```
                   DESC

  s.homepage     = "https://github.com/CoderDwang/DWNetworking"
  s.license      = "MIT"
  s.author             = { "dwanghello" => "dwang.hello@outlook.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/CoderDwang/DWNetworking.git", :tag => s.version.to_s }
  s.source_files  = "DWNetworking", "DWNetworking/**/*.{h,m}"
  s.frameworks  = "Foundation", "UIKit"
  s.dependency "AFNetworking", "~> 3.1.0"
  s.dependency "YYCache", "~> 1.0.4"

end
