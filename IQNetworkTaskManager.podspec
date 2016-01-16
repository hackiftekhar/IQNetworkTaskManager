Pod::Spec.new do |s|
	s.name = "IQNetworkTaskManager"
	s.version = "1.0.0"
	s.summary = "Manage Multiple Network requests with an easy way."
	s.homepage = "https://github.com/hackiftekhar/IQNetworkTaskManager"
	s.screenshots = "https://raw.githubusercontent.com/hackiftekhar/IQNetworkTaskManager/master/Screenshot/Screenshot.jpg"
	s.license = 'MIT'
	s.author = { "Iftekhar Qurashi" => "hack.iftekhar@gmail.com" }
	s.platform = :ios, '6.0'
	s.source = { :git => "https://github.com/hackiftekhar/IQNetworkTaskManager.git", :tag => "v1.0.0" }
	s.source_files = 'IQNetworkTaskManager/*.{h,m}'
    s.dependency = 'IQURLConnection', '1.0.0'
	s.requires_arc = true
end
