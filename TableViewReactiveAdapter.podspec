Pod::Spec.new do |s|
  s.name         = "TableViewReactiveAdapter"
  s.version      = "0.0.1"
  s.summary      = "Small drop-in component which allows UITableView to manipulated in reactive manner through receiving ReactiveCocoa signals."
  s.homepage     = "http://EXAMPLE/TableViewReactiveAdapter"
  s.license      = :type => 'MIT'
  s.author       = { "Sergey Gavrilyuk" => "sergey.gavrilyuk@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "http://EXAMPLE/TableViewReactiveAdapter.git", :tag => "0.0.1" }
  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true
  s.dependency 'ReactiveCocoa', '~> 2.1.8'

end
