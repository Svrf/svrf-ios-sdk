Pod::Spec.new do |s|
          #1.
          s.name               = "SvrfSDK"
          #2.
          s.version            = "1.0.0"
          #3.  
          s.summary         = "SvrfSDK for requests"
          #4.
          s.homepage        = "http://www.svrf.com"
          #5.
          s.license              = ""
          #6.
          s.author               = "SVRF"
          #7.
          s.platform            = :ios, "11.0"
          #8.
          s.source              = { :git => "https://github.com/SVRF/svrf-ios-sdk.git", :tag => "1.0.0" }
          #9.
          s.source_files     = "SvrfSDK/Source/*"
	  #10
          s.dependency       'SVRFClientSwift'
	  s.dependency       'SvrfGLTFSceneKit'
	  s.dependency       'Analytics', '~> 3.0'
          #11
          s.swift_version = "4.0" 
    end