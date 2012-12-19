Pod::Spec.new do |s|
  s.name         = "HPCSMist"
  s.version      = "0.0.1"
  s.summary      = "A delightful networking interface to HP Cloud Services inspired by AFNetworking ."
  s.homepage     = "https://git.hpcloud.net/hagedorm/HPCSMist"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Mike Hagedorn" => "mike.hagedorn@hp.com" }
  s.source       = { :git => "https://git.hpcloud.net/hagedorm/HPCSMist", :tag => "0.0.3"  }
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.7'
  s.source_files = 'Classes/Models/**/*.{h,m}'
  s.requires_arc = true
  s.frameworks =  "Security"
  s.dependency 'AFNetworking'
end
