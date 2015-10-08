require "falcon/version"
require 'heroku_deployer'

module Falcon
  class Deploy

    attr_reader :deployer
    def initialize(environment)
      @deployer = HerokuDeployer.new(environment)
    end

    def run(command)
      return ( puts "The command '#{command}' is not valid. Try `falcon help`." ) unless respond_to?( command )
      send( command )
    end

    def help
      messages = %Q{
        USAGE: `falcon command environment` or `falcon command` (defaults to production)
        ALLOWABLE ENVIRONMENTS: staging, production
        ALLOWABLE COMMANDS: 
        - deploy - push the code
        - migrations - push and run migrations
        - rollback - reverse the latest code push (does NOT reverse migrations)
      }.split("\n")

      messages.each{ |m| puts m }
    end

    def deploy
      puts "you just ran deploy"
      # deployer.deploy
    end

    def migrations
      puts "you just ran migrations"
      # deployer.migrations
    end

    def rollback
      puts "you just ran rollback"
      # deployer.rollback
    end
  end
 
end
