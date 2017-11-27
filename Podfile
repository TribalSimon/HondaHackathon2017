# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!

def google_maps_pods
  pod 'GoogleMaps'
end

target 'HondaHelp' do

  # Pods for HondaHelp
  google_maps_pods

  target 'HondaHelpTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'HondaResponder' do

  # Pods for HondaResponder
  google_maps_pods

  target 'HondaResponderTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
