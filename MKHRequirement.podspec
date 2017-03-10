Pod::Spec.new do |s|

  s.name                      = 'MKHRequirement'
  s.version                   = '1.1.1'
  s.summary                   = 'Describe requirements in a declarative, easy-readable format.'
  s.homepage                  = 'https://github.com/maximkhatskevich/#{s.name}'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }
  s.ios.deployment_target     = '8.0'
  s.source                    = { :git => '#{s.homepage}.git', :tag => '#{s.version}' }
  
  s.requires_arc              = true
  s.social_media_url          = 'http://www.linkedin.com/in/maximkhatskevich'

  s.default_subspec           = 'Core'

  s.subspec 'Core' do |sub|
    sub.source_files          = 'Src/Core/**/*.swift'
  end

  s.subspec 'XCTSupport' do |sub|
    sub.framework             = 'XCTest'
    sub.dependency              'MKHRequirement/Core'
    sub.source_files          = 'Src/XCTSupport/**/*.swift'
  end

end
