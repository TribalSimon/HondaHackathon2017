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

def socket_pods
  pod 'Starscream', '~> 3.0.2'
end

target 'HondaHelp' do

  # Pods for HondaHelp
  alamofire_pods
  google_maps_pods
  socket_pods

  target 'HondaHelpTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'HondaResponder' do

  # Pods for HondaResponder
  alamofire_pods
  google_maps_pods
  socket_pods

  target 'HondaResponderTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'ResponseUnit' do
    
    # Pods for ResponseUnit
    alamofire_pods
    google_maps_pods
    socket_pods
    
end
