require 'spec_helper'
require 'heroku_deployer'
require 'falcon'

describe Falcon do

  it 'has a version number' do
    expect(Falcon::VERSION).not_to be nil
  end

  describe Falcon::Deploy do

    describe "basic functionality" do

      it "responds with instructions when used incorrectly" do
        expect( Falcon::Deploy ).to receive(:help)
        Falcon::Deploy.new('appname').run(:notacommand)
      end

      it "calls migrations correctly" do
        expect_any_instance_of( Falcon::Deploy ).to receive(:migrations)
        Falcon::Deploy.new(:staging).run(:migrations)
      end

      it "runs rollback if approved" do
        expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('prod-name').and_call_original
        expect_any_instance_of( HerokuDeployer ).to receive(:rollback)
        expect( STDIN ).to receive(:gets).and_return('y')

        Falcon::Deploy.new('prod-name').run(:rollback)
      end

      it "blocks rollback unless approved" do
        expect_any_instance_of( HerokuDeployer ).not_to receive(:initialize).with('stage-name').and_call_original
        expect_any_instance_of( HerokuDeployer ).not_to receive(:rollback)
        expect( STDIN ).to receive(:gets).and_return('n')

        Falcon::Deploy.new('stage-name').run(:rollback)
      end

      it "allows for a force argument to circumvent STDIN warning" do
        expect_any_instance_of( HerokuDeployer ).to receive(:initialize).with('name').and_call_original
        expect_any_instance_of( HerokuDeployer ).to receive(:rollback)

        Falcon::Deploy.new('name', true).run(:rollback)
      end
    end

    # describe "command line functionality" do
    #   it "responds with instructions when used incorrectly" do
    #     expect( `falcon blah` ).to eq ''
    #     expect( `falcon blah blah blah` ).to eq ''
    #     expect( `falcon help` ).to eq ''
    #     expect( `falcon appname notacommand` ).to eq ''
    #   end

    #   it "asks for approval before calling rollback" do
    #     # expect_any_instance_of( Falcon::Deploy ).to receive(:initialize).with(:explicit, nil).and_return( nil )
    #     expect( `falcon appname rollback` ).to eq ''
    #   end

    #   it "calls the right methods" do
    #     allow_any_instance_of( Falcon::Deploy ).to receive(:deploy).and_return("Deploying")
    #     allow_any_instance_of( Falcon::Deploy ).to receive(:migrations).and_return("Migrating")
    #     allow_any_instance_of( Falcon::Deploy ).to receive(:rollback).and_return("Rolling back")
        
    #     expect( `falcon appname deploy` ).to eq 'Deploying'
    #     expect( `falcon appname migrations` ).to eq 'Migrating'
    #     expect( `falcon appname rollback` ).to eq 'Rolling back'
    #   end
    # end
  end
end
