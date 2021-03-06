#!/usr/bin/env ruby

raise "Usage: at-change [--initial] <command> <glob pattern>..." unless ARGV.length >= 2

initial = false
if ARGV[0] == '--initial'
	initial = true
	ARGV.shift
end

to_run = ARGV[0]
patterns = ARGV[1, ARGV.length - 1]
puts patterns.inspect

substitute = (to_run.index "{}")

file_mtimes = {}
unless initial
	patterns.each do |pattern|
		Dir[pattern].each do |file|
			file_mtimes[file] = File.mtime(file)
		end
	end
end

loop do	
	needs_to_run = false
	
	patterns.each do |pattern|
		Dir[pattern].each do |file|
			mtime = File.mtime(file)
		
			if not file_mtimes[file] or file_mtimes[file] < mtime
				file_mtimes[file] = mtime
				if substitute
					command = to_run.gsub("{}", file)
					puts "$ #{command}"
					puts `#{command}`
				else
					needs_to_run = true
				end
			end
		end
		
		break if needs_to_run
	end
	
	if not substitute and needs_to_run
		puts "$ #{to_run}"
		puts `#{to_run}`
	end

	sleep 2
end
