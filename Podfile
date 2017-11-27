# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!

def alamofire_pods
    pod 'Alamofire', '~> 4.5'
    pod 'AlamofireObjectMapper', '~> 5.0'
end

def google_maps_pods
  pod 'GoogleMaps'
end

target 'HondaHelp' do

  # Pods for HondaHelp
  alamofire_pods
  google_maps_pods

  target 'HondaHelpTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'HondaResponder' do

  # Pods for HondaResponder
  alamofire_pods
  google_maps_pods

  target 'HondaResponderTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
