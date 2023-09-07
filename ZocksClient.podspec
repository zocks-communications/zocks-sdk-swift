Pod::Spec.new do |spec|

  spec.name         = 'ZocksClient'
  spec.version      = '1.0.0'
  spec.summary      = 'Zocks Swift Client SDK.'
  spec.homepage     = 'https://docs.zocks.io/'
  spec.author       = 'LiveKit'

  spec.ios.deployment_target = '13.0'
  spec.osx.deployment_target = '10.15'

  spec.swift_versions = ['4.2', '5']

  spec.source_files   = 'Sources/**/*'

  spec.dependency 'LiveKit'

end
