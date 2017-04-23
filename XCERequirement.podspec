projName = 'Requirement'
projSummary = 'Describe requirements in a declarative, easy-readable format.'
companyPrefix = 'XCE'
companyName = 'XCEssentials'
companyGitHubAccount = 'https://github.com/' + companyName

#===

Pod::Spec.new do |s|

  s.name                      = companyPrefix + projName
  s.summary                   = projSummary
  s.version                   = '1.4.0'
  
  s.source                    = { :git => companyGitHubAccount + '/' + projName + '.git', :tag => '#{s.version}' }
  s.source_files              = 'Src/**/*.swift'

  s.ios.deployment_target     = '8.0'
  s.requires_arc              = true
  
  # s.dependency                'AAA', '~> X.Y.Z'

  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }
  
end
