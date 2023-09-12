Pod::Spec.new do |spec|

  spec.name         = 'ZocksClient'
  spec.version      = '1.0.1'
  spec.summary      = 'Zocks Swift Client SDK.'
  spec.homepage     = 'https://docs.zocks.io/'
  spec.author       = 'Zocks'

  spec.ios.deployment_target = '13.0'
  spec.osx.deployment_target = '10.15'

  spec.swift_versions = ['4.2', '5']

  spec.source         = { :git => 'https://github.com/zocks-communications/zocks-sdk-swift.git', :tag => '1.0.1' }
  spec.source_files   = 'Sources/Zocks/**/*.{swift, plist}'
  spec.resources      = 'Sources/Resources/**/*.{storyboard,xib,xcassets,json,png}'

  spec.dependency 'LiveKit'

end
