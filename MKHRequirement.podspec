Pod::Spec.new do |s|

  s.name                      = 'MKHRequirement'
  s.version                   = '1.1.2'
  s.summary                   = 'Describe requirements in a declarative, easy-readable format.'
  s.homepage                  = 'https://github.com/maximkhatskevich/#{s.name}'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }
  s.ios.deployment_target     = '8.0'
  s.source                    = { :git => '#{s.homepage}.git', :tag => '#{s.version}' }
  
  s.requires_arc              = true
  s.social_media_url          = 'http://www.linkedin.com/in/maximkhatskevich'

  s.source_files              = 'Src/**/*.swift'

end
