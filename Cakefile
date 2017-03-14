# https://github.com/jcampbell05/xcake
# http://www.rubydoc.info/github/jcampbell05/xcake/master/file/docs/Cakefile.md

#=== GLOBAL SETTINGS ===

repoName            = 'MKHRequirement'
companyIdentifier   = 'khatskevich.maxim'
organizationName    = 'Maxim Khatskevich'
developmentTeamId   = 'Maxim Khatskevich' # 'UJA88X59XP'

targetDeviceFamily  = '1,2'
iOSdeploymentTarget = '8.0'
currentSwiftVersion = '3.0'
testSuffix          = 'Tst'

cfgDebug = 'Debug'
cfgRelease = 'Release'

#=== SPEC ===

project.name = 'Main'
project.organization = organizationName

#===

project.all_configurations.each do |c|

    #--- PROJECT-related settings

    c.settings['DEVELOPMENT_TEAM'] = developmentTeamId

    c.settings['TARGETED_DEVICE_FAMILY'] = targetDeviceFamily
    c.settings['IPHONEOS_DEPLOYMENT_TARGET'] = iOSdeploymentTarget
    c.settings['SWIFT_VERSION'] = currentSwiftVersion
    
    #--- OTHER settings

    c.settings['CURRENT_PROJECT_VERSION'] = '0' # just default non-empty value

    c.settings['SDKROOT'] = 'iphoneos'
    c.settings['VERSIONING_SYSTEM'] = 'apple-generic'

    #---

    # c.settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = ''
    # c.settings['GCC_NO_COMMON_BLOCKS'] = 'YES'
    # c.settings['GCC_WARN_ABOUT_RETURN_TYPE'] = 'YES_ERROR'
    # c.settings['GCC_WARN_UNINITIALIZED_AUTOS'] = 'YES_AGGRESSIVE'
    # c.settings['CLANG_WARN_DIRECT_OBJC_ISA_USAGE'] = 'YES_ERROR'
    # c.settings['CLANG_WARN_OBJC_ROOT_CLASS'] = 'YES_ERROR'
    # c.settings['CLANG_WARN_INFINITE_RECURSION'] = 'YES' # Xcode 8
    # c.settings['CLANG_WARN_SUSPICIOUS_MOVE'] = 'YES' # Xcode 8
    # c.settings['ENABLE_STRICT_OBJC_MSGSEND'] = 'YES' # Xcode 8
    # c.settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'

    #---

    if c.name == cfgDebug

        # c.settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'

    end

    #---

    if c.name == cfgRelease

        # c.settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
        # c.settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'

    end

end

#=== Targets

target do |t|

    t.name = repoName
    
    t.platform = :ios
    t.type = :framework

    # t.language = :swift # ???
    # t.deployment_target = iOSdeploymentTarget

    t.include_files = ['Src/**/*.*']
    # t.include_files << 'Src-Extra/**/*.*'

    t.all_configurations.each do |c|

        c.settings['PRODUCT_BUNDLE_IDENTIFIER'] = companyIdentifier + '.' + repoName
        c.settings['INFOPLIST_FILE'] = 'Info/Fwk.plist'
        # c.settings['PRODUCT_NAME'] = '$(TARGET_NAME)'

        c.settings['DEFINES_MODULE'] = 'YES'
        c.settings['SKIP_INSTALL'] = 'YES'

    end

    #=== Tests
    
    unit_tests_for target do |ut|
        
        ut.name = testSuffix

        # ut.deployment_target = iOSdeploymentTarget

        ut.all_configurations.each do |c|

            c.settings['PRODUCT_BUNDLE_IDENTIFIER'] = companyIdentifier + '.' + repoName + '.' + testSuffix
            c.settings['INFOPLIST_FILE'] = 'Info/' + testSuffix + '.plist'
            c.settings['FRAMEWORK_SEARCH_PATHS'] = '$(inherited) $(BUILT_PRODUCTS_DIR)'
            # c.settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @loader_path/Frameworks'
            
            # c.settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = ''

        end

        #=== Source Files

        testTargetSrcPath = testSuffix + '/**/*.*'

        ut.include_files = [testTargetSrcPath]

    end

end