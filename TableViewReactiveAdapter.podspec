Pod::Spec.new do |s|
  s.name         = "TableViewReactiveAdapter"
  s.version      = "0.0.2"
  s.summary      = "Small drop-in component which allows UITableView to manipulated in reactive manner through receiving ReactiveCocoa signals."
  s.homepage     = "https://github.com/gavrix/TableViewReactiveAdapter"
  s.license      = { :type => 'MIT' }
  s.author       = { "Sergey Gavrilyuk" => "sergey.gavrilyuk@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/gavrix/TableViewReactiveAdapter.git", :tag => "0.0.1" }
  s.source_files  = 'TableViewReactiveAdapter/TableViewReactiveAdapter/*.{h,m}'
  s.requires_arc = true

  s.dependency 'ReactiveCocoa', '~> 2'
  s.dependency 'libextobjc', '0.3'

end
