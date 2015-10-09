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

    describe "command line functionality" do
      it "defaults takes an explicit app" do
        expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('my-explicit-app', nil).and_call_original
        expect_any_instance_of( HerokuDeployer ).to receive(:migrations).and_return(nil)
        `falcon migrations -n my-explicit-app`
      end

      it "asks for approval before calling rollback" do
        expect_any_instance_of( HerokuDeployer ).not_to receive(:rollback)
        `falcon rollback -n my-explicit-app`
      end

      it "can take a force argument to override rollback warning" do
        expect_any_instance_of( HerokuDeployer ).to receive(:rollback).and_return(nil)
        `falcon rollback -n my-explicit-app -f`
      end
    end
  end
end
