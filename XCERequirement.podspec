Pod::Spec.new do |s|

    s.name          = 'XCERequirement'
    s.summary       = 'Describe requirements in a declarative, easy-readable format'
    s.version       = '0.0.1'
    s.homepage      = 'https://XCEssentials.github.io/Requirement'

    s.source        = { :git => 'https://github.com/XCEssentials/Requirement.git', :tag => s.version }

    s.requires_arc  = true

    s.license       = { :type => 'MIT', :file => 'LICENSE' }

    s.authors = {
        'Maxim Khatskevich' => 'maxim@khatskevi.ch'
    } # authors

    s.swift_version = '5.0'

    s.cocoapods_version = '>= 1.7.0'

    # === ios

    s.ios.deployment_target = '9.0'

    # === watchos

    s.watchos.deployment_target = '3.0'

    # === tvos

    s.tvos.deployment_target = '9.0'

    # === osx

    s.osx.deployment_target = '10.11'

    # === SUBSPECS ===

    s.subspec 'Core' do |ss|

        ss.source_files = 'Sources/Core/**/*'

    end # subspec 'Core'

    s.test_spec 'AllTests' do |ss|

        ss.requires_app_host = false
        ss.source_files = 'Tests/AllTests/**/*'

    end # test_spec 'AllTests'

end # spec s
