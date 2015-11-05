require "falcon/version"
require 'heroku_deployer'

module Falcon

  class Deploy

    attr_reader :env, :appname, :force
    def initialize(appname, force=false)
      @appname = appname
      @force = force
    end

    def self.help
      %Q{
        USAGE: `falcon [appname] [command] [flags]`
        APPNAME: Your Heroku app name
        COMMANDS: 
        - `deploy` - deploy the code
        - `migrations` - deploy and run migrations
        - `rollback` - reverse the latest code deploy (does NOT reverse migrations)
        FLAGS
        - `-f`, `--force` - force rollback etc
      }
    end

    def run(command)
      if respond_to? command
        send command
      else
        puts "The command '#{command}' is not valid.\n"
        puts self.class.help
      end
    end

    def deploy
      deployer.deploy
    end

    def migrations
      deployer.migrations
    end

    def rollback
      unless force
        puts rollback_warning
        
        answer = STDIN.gets.strip

        return (puts "Rollback cancelled.") unless %w( y yes ).include?( answer.downcase )
      end

      deployer.rollback
    end

    def deployer
      @deployer ||= HerokuDeployer.new( appname )
    end

    def rollback_warning
      %Q{
        This command does NOT reverse migrations. 
        If you want to reverse a migration, please do so manually:
          `heroku run rake db:rollback`
        Then run this command again.

        Continue (without DB rollback)? Y/N
      }
    end
  end
 
end
