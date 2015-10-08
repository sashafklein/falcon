require "falcon/version"
require 'heroku_deployer'

module Falcon

  class Configuration
    attr_accessor :staging_app, :production_app
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield( configuration )
    puts configuration
  end

  class Deploy

    attr_reader :env
    def initialize(environment)
      @env = environment
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
        USAGE: `falcon command environment` or `falcon command` (defaults to production)
        ALLOWABLE ENVIRONMENTS: staging, production
        ALLOWABLE COMMANDS: 
        - deploy - deploy the code
        - migrations - deploy and run migrations
        - rollback - reverse the latest code deploy (does NOT reverse migrations)
      }
    end

    def deploy
      deployer.deploy
    end

    def migrations
      deployer.migrations
    end

    def rollback
      puts %Q{
        This command does NOT reverse migrations. 
        If you want to reverse a migration, please do so manually:
          `heroku run rake db:rollback`
        Then run this command again.

        Continue (without DB rollback)? Y/N
      }

      answer = STDIN.gets.strip

      return (puts "Rollback cancelled.") unless %w( y yes ).include?( answer.downcase )
      deployer.rollback
    end

    def deployer
      @deployer ||= HerokuDeployer.new( self.class.configuration[ "#{ env }_app" ] )
    end
  end
 
end
