Pod::Spec.new do |s|
    s.name             = 'GGXOfflineWebCache'
    s.version          = '1.0.0'
    s.summary          = '默认下载离线策略为3'
    
    s.description      = <<-DESC
    TODO: Add long description of the pod here.
    DESC
    
    s.homepage         = 'https://github.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { '小修' => 'gaoguangxiao125@sina.com' }
    s.source           = { :git => 'https://github.com/gaoguangxiao/GGXOfflineWebCache.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '13.0'
    s.swift_version = '5.0'
    s.source_files = 'GGXOfflineWebCache/Classes/**/*'
    
    s.dependency 'GGXSwiftExtension'
    s.dependency 'GXTaskDownload'
    s.dependency 'SSZipArchive'
    s.dependency 'GXSwiftNetwork'
    s.dependency 'PTDebugView'
    
end
