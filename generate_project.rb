require 'xcodeproj'

project_name = 'HelloWorld'
project_path = "#{project_name}.xcodeproj"

# Create a new Xcode project
project = Xcodeproj::Project.new(project_path)

# Set the target
target = project.new_target(:application, project_name, :ios, '15.0')

# Add Swift files from ios_client
Dir.glob('ios_client/**/*.swift').each do |file_path|
  file_ref = project.main_group.new_file(file_path)
  target.add_file_references([file_ref])
end

# Add Bridging Header
bridging_header = 'ios_client/Core/CoreBridge-Bridging-Header.h'
project.main_group.new_file(bridging_header)

# Add Rust library (it will be built by Codemagic)
lib_path = 'target/aarch64-apple-ios/release/libhelloworld_core.a'
# We don't add the file reference if it doesn't exist yet, but we need to tell the linker where to find it
target.build_configurations.each do |config|
  s = config.build_settings
  s['CODE_SIGNING_ALLOWED'] = 'NO'
  s['CODE_SIGNING_REQUIRED'] = 'NO'
  s['CODE_SIGN_IDENTITY'] = ''
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.helloworld.messenger'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  s['SWIFT_VERSION'] = '5.0'
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['INFOPLIST_KEY_CFBundleExecutable'] = 'HelloWorld'
  s['SWIFT_OBJC_BRIDGING_HEADER'] = bridging_header
  s['LIBRARY_SEARCH_PATHS'] = '$(inherited) $(PROJECT_DIR)/target/aarch64-apple-ios/release'
  s['OTHER_LDFLAGS'] = '$(inherited) -lhelloworld_core -framework Security -framework Foundation'
end

# Create a scheme
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.save_as(project.path, project_name, true)

# Save the project
project.save
puts "Project #{project_name} generated successfully."
