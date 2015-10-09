require 'spec_helper'
require 'ostruct'
require 'heroku_deployer'

describe Falcon do

  it 'has a version number' do
    expect(Falcon::VERSION).not_to be nil
  end

  describe Falcon::Deploy do

    describe 'configuration' do

      before do 
        Falcon.configure do |config|
          config.staging_app = 'staging_app_name'
        end
      end

      it "saves the configuration to the deployer object" do
        Falcon.configure{ |c| c.production_app = 'production_app_name' }

        expect( Falcon::Deploy.new(:staging).deployer.app ).to eq 'staging_app_name'
        expect( Falcon::Deploy.new(:production).deployer.app ).to eq 'production_app_name'
      end

      it "throws an initialization error without the right app" do
        Falcon.configure{ |c| c.production_app = nil }

        expect( Falcon::Deploy.new(:staging).deployer.app ).to eq 'staging_app_name'
        expect{ Falcon::Deploy.new(:production).deployer.app }.to raise_error
      end
    end

    describe "basic functionality" do

      before do 
        Falcon.configure do |c| 
          c.staging_app = 'staging-name'
          c.production_app = 'prod-name'
          c.explicit_app = 'explicit-name'
        end
      end

      it "calls the right deployer functions with the right environment" do
        expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('staging-name').and_call_original
        expect_any_instance_of( HerokuDeployer ).to receive(:migrations).and_return(nil)

        Falcon::Deploy.new(:staging).migrations
      end

      it "runs rollback if approved" do
        expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('prod-name').and_call_original
        expect_any_instance_of( HerokuDeployer ).to receive(:rollback)
        expect( STDIN ).to receive(:gets).and_return('y')

        Falcon::Deploy.new(:production).rollback      
      end

      it "blocks rollback unless approved" do
        expect_any_instance_of( HerokuDeployer ).not_to receive(:initialize)
        expect_any_instance_of( HerokuDeployer ).not_to receive(:rollback)
        expect( STDIN ).to receive(:gets).and_return('n')

        Falcon::Deploy.new(:staging).rollback
      end

      it "allows for a force argument to circumvent STDIN warning" do
        expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('explicit-name').and_call_original
        expect_any_instance_of( HerokuDeployer ).to receive(:rollback)

        Falcon::Deploy.new(:explicit, true).rollback
      end
    end

    describe "command line functionality" do
      # TODO: The expectations just aren't setting.

      # it "can take an explicit app flag" do
      #   expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('my-explicit-app', nil).and_call_original
      #   expect_any_instance_of( HerokuDeployer ).to receive(:migrations).and_return(nil)
      #   `falcon migrations -n my-explicit-app`
      # end

      # it "asks for approval before calling rollback" do
      #   expect_any_instance_of( Falcon::Deploy ).to receive(:initialize).with(:explicit, nil).and_return( nil )
      #   `falcon rollback -n my-explicit-app`
      # end

      # it "can take a force argument to override rollback warning" do
      #   expect_any_instance_of( Falcon::Deploy ).to receive(:initialize).with(:explicit, true).and_return( nil )
      #   `falcon rollback -n my-explicit-app -f`
      # end
    end
  end
end
