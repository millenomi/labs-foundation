
module ILabs
	module Rake
		def common_tasks(*namespaces)
			desc "Builds namespaces: #{namespaces.join ', '}"
			task :build

			desc "Cleans namespaces: #{namespaces.join ', '}"
			task :clean
			
			desc "Clobbers namespaces: #{namespaces.join ', '}"
			task :clobber
			
			namespaces.each do |n|
				task :build => "#{n}:build"
				task :clean => "#{n}:clean"
				task :clobber => "#{n}:clobber"
			end
		end
		
		def android(path)
			desc "Builds Android project at #{path}"
			task :build do
				cd path
				sh 'ant', 'compile'
			end
			
			task :clean do
				cd path
				sh 'ant', 'clean'
			end
			
			task :clobber do
				cd path
				sh 'ant', 'clean'
			end
		end
		
		def xcode(path, options = {})
			project_path = path
			if path.end_with? '.xcodeproj'
				project_name = File.basename(project_path)
				project_path = File.dirname(project_path)
			end
	
			target = options[:target]
			configuration = options[:configuration]
			xcconfig = options[:xcconfig]
			build_settings = options[:build_settings] || {}
	
			args = ['xcodebuild']
	
			if project_name
				args << '-project'
				args << project_name
			end
	
			if target
				args << '-target'
				args << target
			end
	
			if configuration
				args << '-configuration'
				args << configuration
			end
	
			if xcconfig
				args << '-xcconfig'
				args << xcconfig
			end
	
			build_settings.each do |k,v|
				args << "#{k}=#{v}"
			end
	
			desc "Builds Xcode project at #{project_path}"
			task :build do
				cd project_path
		
				invocation = args.dup
				invocation << 'build'
		
				sh(*invocation)
			end
	
			desc "Cleans Xcode project at #{project_path}"
			task :clean do
				cd project_path
		
				invocation = args.dup
				invocation << 'clean'
		
				sh(*invocation)
			end
			
			desc "Cleans Xcode project at #{project_path}, then removes the 'build' folder"
			task :clobber do
				cd project_path

				invocation = args.dup
				invocation << 'clean'
		
				sh(*invocation)
				rm_rf 'build'
			end
		end
	end
end
