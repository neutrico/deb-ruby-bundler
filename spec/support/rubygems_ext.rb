require 'rubygems/user_interaction'

module Spec
  module Rubygems
    def self.setup
      Gem.clear_paths

      ENV['BUNDLE_PATH'] = nil
      ENV['GEM_HOME'] = ENV['GEM_PATH'] = Path.base_system_gems.to_s
      ENV['PATH'] = ["#{Path.root}/bin", "#{Path.system_gem_path}/bin", ENV['PATH']].join(File::PATH_SEPARATOR)

      unless File.exist?("#{Path.base_system_gems}")
        FileUtils.mkdir_p(Path.base_system_gems)
        puts "running `gem install rake fakeweb --no-rdoc --no-ri`"
        `gem install fakeweb --no-rdoc --no-ri`
        # Rake version has to be consistent for tests to pass
        `gem install rake --version 0.8.7 --no-rdoc --no-ri`
        # 3.0.0 breaks 1.9.2 specs
        puts "running `gem install builder --version 2.1.2 --no-rdoc --no-ri`"
        `gem install builder --version 2.1.2 --no-rdoc --no-ri`
      end

      ENV['HOME'] = Path.home.to_s

      Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
    end

    def gem_command(command, args = "", options = {})
      if command == :exec && !options[:no_quote]
        args = args.gsub(/(?=")/, "\\")
        args = %["#{args}"]
      end
      lib  = File.join(File.dirname(__FILE__), '..', '..', 'lib')
      %x{#{Gem.ruby} -I#{lib} -rubygems -S gem --backtrace #{command} #{args}}.strip
    end
  end
end
