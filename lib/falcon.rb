require "falcon/version"
require 'heroku_deployer'

module Falcon

  class Configuration
    attr_accessor :staging_app, :production_app, :explicit_app, :force
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield( configuration )
  end

  class Deploy

    attr_reader :env, :app_name, :force
    def initialize(environment, force=false)
      @env = environment
      @app_name = Falcon.configuration.send( "#{ env }_app" )
      @force = force
    end

    def run(command)
      if respond_to? command
        send command
      else
        puts "The command '#{command}' is not valid.\n"
        help
      end
    end

    def help
      puts %Q{
        USAGE: `falcon [command] [environment] [flags]` or `falcon [command] [flags]` (env defaults to production)
        ENVIRONMENTS: `staging`, `production`
        COMMANDS: 
        - `deploy` - deploy the code
        - `migrations` - deploy and run migrations
        - `rollback` - reverse the latest code deploy (does NOT reverse migrations)
        FLAGS
        - `-n`, `--name` - explicit app name (raises error if environment given)
        - `-f`, `--force` - force rollback etc
      }
    end

    def deploy
      deployer.deploy
    end

    def migrations
      deployer.migrations
    end

    def rollback
      unless force
        puts %Q{
          This command does NOT reverse migrations. 
          If you want to reverse a migration, please do so manually:
            `heroku run rake db:rollback`
          Then run this command again.

          Continue (without DB rollback)? Y/N
        }

        answer = STDIN.gets.strip

        return (puts "Rollback cancelled.") unless %w( y yes ).include?( answer.downcase )
      end

      deployer.rollback
    end

    def deployer
      @deployer ||= HerokuDeployer.new( app_name )
    end
  end
 
end
