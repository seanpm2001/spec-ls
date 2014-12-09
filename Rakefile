# encoding: utf-8

require 'etc'
require 'fileutils'
require 'json'
require 'rake/clean'

@lib_loom_config = nil
@test_loom_config = nil

CLEAN.include ["lib/build/**", "test/bin/**"]
CLOBBER.include ["lib/build", "test/bin", "releases"]
Rake::Task[:clobber].enhance ["lib:uninstall"]


task :default => :list_targets

task :list_targets do |t, args|
	lib_sdk = lib_config['sdk_version']
	test_sdk = test_config['sdk_version']
	puts "Spec Rakefile running on Ruby #{RUBY_VERSION}"
	puts "  lib SDK:  #{lib_sdk}"
	puts "  test SDK: #{test_sdk}"
	system("rake -T")
	puts ''
end


LIBRARY = "lib/build/Spec.loomlib"

FileList['lib/src/**/*.ls'].each do |src|
	file LIBRARY => src
end

file LIBRARY do |t, args|
	puts "[file] creating #{t.name}..."

	sdk_version = lib_config['sdk_version']

	Dir.chdir("lib") do
		Dir.mkdir('build') unless Dir.exists?('build')
		cmd = %Q[#{sdk_root}/#{sdk_version}/tools/lsc Spec.build]
		try(cmd, "failed to compile .loomlib")
	end

	puts ''
end


APP = "test/bin/SpecTest.loom"

FileList['test/src/**/*.ls'].each do |src|
	file APP => src
end

file APP => LIBRARY do |t, args|
	puts "[file] creating #{t.name}..."

	sdk_version = test_config['sdk_version']
	file_installed = "#{sdk_root}/#{sdk_version}/libs/Spec.loomlib"

	Rake::Task["lib:install"].invoke unless FileUtils.uptodate?(file_installed, [LIBRARY])

	Dir.chdir("test") do
		Dir.mkdir('bin') unless Dir.exists?('bin')
		cmd = %Q[#{sdk_root}/#{sdk_version}/tools/lsc SpecTest.build]
		try(cmd, "failed to compile .loom")
	end

	puts ''
end


desc "sets the provided SDK version into lib/loom.config and test/loom.config"
task :set, [:sdk] => "lib:uninstall" do |t, args|
	args.with_defaults(:sdk => 'sprint33')
	sdk_version = args.sdk

	lib_config['sdk_version'] = sdk_version
	test_config['sdk_version'] = sdk_version

	write_lib_config(lib_config)
	write_test_config(test_config)

	puts "[#{t.name}] task completed, sdk updated to #{sdk_version}"
	puts ''
end

namespace :lib do

	desc "builds Spec.loomlib for the SDK specified in lib/loom.config"
	task :build => LIBRARY do |t, args|
		puts "[#{t.name}] task completed, find .loomlib in lib/build/"
		puts ''
	end

	desc "prepares sdk-specific Spec.loomlib for release"
	task :release => LIBRARY do |t, args|
		lib = 'lib/build/Spec.loomlib'
		sdk = lib_config['sdk_version']
		ext = '.loomlib'
		release_dir = 'releases'

		Dir.mkdir(release_dir) unless Dir.exists?(release_dir)

		lib_release = %Q[#{File.basename(lib, ext)}-#{sdk}#{ext}]
		FileUtils.copy(lib, "#{release_dir}/#{lib_release}")

		puts "[#{t.name}] task completed, find #{lib_release} in #{release_dir}/"
		puts ''
	end

	desc "installs Spec.loomlib into the SDK specified in lib/loom.config"
	task :install => LIBRARY do |t, args|
		lib = 'lib/build/Spec.loomlib'
		sdk_version = lib_config['sdk_version']
		libs_path = "#{sdk_root}/#{sdk_version}/libs"

		cmd = %Q[cp #{lib} #{libs_path}]
		try(cmd, "failed to install lib")

		puts "[#{t.name}] task completed, Spec.loomlib installed for #{sdk_version}"
		puts ''
	end

	desc "removes Spec.loomlib from the SDK specified in lib/loom.config"
	task :uninstall do |t, args|
		sdk_version = lib_config['sdk_version']
		lib = "#{sdk_root}/#{sdk_version}/libs/Spec.loomlib"

		if (File.exists?(lib))
			cmd = %Q[rm -f #{lib}]
			try(cmd, "failed to remove lib")
			puts "[#{t.name}] task completed, Spec.loomlib removed from #{sdk_version}"
		else
			puts "[#{t.name}] nothing to do;  no Spec.loomlib found in #{sdk_version} sdk"
		end
		puts ''
	end

	desc "lists libs installed for the SDK specified in lib/loom.config"
	task :show do |t, args|
		sdk_version = lib_config['sdk_version']

		cmd = %Q[ls -l #{sdk_root}/#{sdk_version}/libs]
		try(cmd, "failed to list contents of #{sdk_version} libs directory")

		puts ''
	end

end

namespace :test do

	desc "builds SpecTest.loom with the SDK specified in test/loom.config"
	task :build => APP do |t, args|
		puts "[#{t.name}] task completed, find .loom in test/bin/"
		puts ''
	end

	desc "runs SpecTest.loom"
	task :run => APP do |t, args|
		puts "[#{t.name}] running #{t.prerequisites[0]}..."

		sdk_version = test_config['sdk_version']
		cmd = %Q[#{sdk_root}/#{sdk_version}/tools/loomexec test/bin/SpecTest.loom --format ansi]
		try(cmd, "failed to run .loom")

		puts ''
	end

	desc "runs SpecTest.loom for CI"
	task :ci => APP do |t, args|
		puts "[#{t.name}] running #{t.prerequisites[0]}..."

		sdk_version = test_config['sdk_version']
		cmd = %Q[#{sdk_root}/#{sdk_version}/tools/loomexec test/bin/SpecTest.loom --format junit --format console]
		try(cmd, "failed to run .loom")

		puts ''
	end

end


def lib_config_file
	File.join('lib', 'loom.config')
end

def test_config_file
	File.join('test', 'loom.config')
end

def lib_config
	@lib_loom_config || (@lib_loom_config = JSON.parse(File.read(lib_config_file)))
end

def test_config
	@test_loom_config || (@test_loom_config = JSON.parse(File.read(test_config_file)))
end

def write_lib_config(config)
	File.open(lib_config_file, 'w') { |f| f.write(JSON.pretty_generate(config)) }
end

def write_test_config(config)
	File.open(test_config_file, 'w') { |f| f.write(JSON.pretty_generate(config)) }
end

def home
	ENV['LOOM_HOME'] || Dir.home
end

def sdk_root
	File.join(home, '.loom', 'sdks')
end

def try(cmd, failure_message)
	abort("◈ #{failure_message}") if (exec_with_echo(cmd) != 0)
end

def exec_with_echo(cmd)
	puts(cmd)
	stdout = %x[#{cmd}]
	puts(stdout) unless stdout.empty?
	$?.exitstatus
end
