Pod::Spec.new do |s|
  s.name = "SvrfSDK"
  s.version = "1.1.0"
  s.summary = "The SvrfSDK is a framework for easy integration of the SVRF API"
  s.homepage = "http://www.svrf.com"
  s.license = "MIT"
  s.author = "SVRF"
  s.platform = :ios, "11.0"
  s.source = { :git => "https://github.com/SVRF/svrf-ios-sdk.git", :tag => "1.1.0" }
  s.source_files = "SvrfSDK/Source/*"
  s.dependency 'SVRFClient', '~> 1.6.0'
  s.dependency 'SvrfGLTFSceneKit', '~> 1.0'
  s.dependency 'Analytics', '~> 3.0'
  s.swift_version = "4.0"
end