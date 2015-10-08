require 'spec_helper'

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
        Falcon.configure do |config|
          config.production_app = 'production_app_name'
        end

        expect( Falcon::Deploy.new(:staging).deployer.app ).to eq 'staging_app_name'
        expect( Falcon::Deploy.new(:production).deployer.app ).to eq 'production_app_name'
      end

      it "throws an initialization error without the right app" do
        expect( Falcon::Deploy.new(:staging).deployer.app ).to eq 'staging_app_name'
        expect( Falcon::Deploy.new(:production).deployer.app ).to raise_error
      end
    end
  end
end
