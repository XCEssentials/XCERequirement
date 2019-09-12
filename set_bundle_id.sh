#!/bin/bash

# http://www.grymoire.com/Unix/Sed.html#TOC
sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \"XCERequirement\"|PRODUCT_BUNDLE_IDENTIFIER = com.XCEssentials.Requirement|g" XCERequirement.xcodeproj/project.pbxproj
