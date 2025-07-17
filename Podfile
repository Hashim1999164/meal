# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Meal' do
  # Comment the next line if you don't want to use dynamic frameworks
  pod 'FirebaseCore'
  # Firestore Database
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  # Authentication (for anonymous login)
  pod 'FirebaseAuth'
  use_frameworks!

  # Pods for Meal

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
