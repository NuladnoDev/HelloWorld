require 'xcodeproj'

project_name = 'HelloWorld'
project_path = "#{project_name}.xcodeproj"

# Create a new Xcode project
project = Xcodeproj::Project.new(project_path)

# Set the target
target = project.new_target(:application, project_name, :ios, '15.0')

# Create groups
app_group = project.main_group.find_subpath('ios_client', true)
core_group = app_group.find_subpath('Core', true)
resources_group = app_group.find_subpath('Resources', true)
views_group = app_group.find_subpath('Views', true)

# Add Swift files
Dir.glob('ios_client/Views/*.swift').each do |file_path|
  file_ref = views_group.new_file(file_path)
  target.add_file_references([file_ref])
end

# core_wrapper_path = 'ios_client/Core/CoreWrapper.swift'
# core_wrapper_ref = core_group.new_file(core_wrapper_path)
# target.add_file_references([core_wrapper_ref])

# Add Resources
launch_screen_path = 'ios_client/Resources/LaunchScreen.storyboard'
launch_screen_ref = resources_group.new_file(launch_screen_path)
target.add_resources([launch_screen_ref])

# Info.plist
info_plist_path = 'ios_client/Resources/Info.plist'
resources_group.new_file(info_plist_path)

# Bridging Header
bridging_header_path = 'ios_client/Core/CoreBridge-Bridging-Header.h'
core_group.new_file(bridging_header_path)

# Add Rust library
# lib_path = 'target/aarch64-apple-ios/release/libhelloworld_core.a'
# if File.exist?(lib_path)
#   lib_ref = project.frameworks_group.new_file(lib_path)
#   target.frameworks_build_phase.add_file_reference(lib_ref)
# end

# Build settings
target.build_configurations.each do |config|
  s = config.build_settings
  s['CODE_SIGNING_ALLOWED'] = 'NO'
  s['CODE_SIGNING_REQUIRED'] = 'NO'
  s['CODE_SIGN_IDENTITY'] = ''
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.helloworld.messenger'
  s['PRODUCT_NAME'] = project_name
  s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  s['SWIFT_VERSION'] = '5.0'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['INFOPLIST_FILE'] = 'ios_client/Resources/Info.plist'
  s['SWIFT_OBJC_BRIDGING_HEADER'] = 'ios_client/Core/CoreBridge-Bridging-Header.h'
  s['LIBRARY_SEARCH_PATHS'] = '$(inherited) $(PROJECT_DIR)/target/aarch64-apple-ios/release'
  s['OTHER_LDFLAGS'] = '$(inherited) -framework Security -framework Foundation -framework UIKit'
  s['ENABLE_BITCODE'] = 'NO'
  s['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
  s['SDKROOT'] = 'iphoneos'
end

# Create a scheme
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.save_as(project_path, project_name)

# Save the project
project.save
puts "Project #{project_name} generated successfully with improved structure."
