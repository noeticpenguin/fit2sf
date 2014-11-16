class RunkeeperController < ApplicationController
	include HTTParty

	require 'digest/md5'

	before_action :setup_health_graph

	def index
		@rk = Rk.last
		@user = HealthGraph::User.new(@rk.authtoken)
		redirect_to action: 'authorize' if @user.nil?
		@fitness_activities = @user.fitness_activities.items
		@fit = @user.fitness_activity @user.fitness_activities.items.first

		@client = Restforce.new :username => 'kjp-5k@codefriar.com',
			:password       => 'stargatesg1;',
			:security_token => 'rfkepEzXp8pJIzx1Irq0PkDM',
			:client_id      => '3MVG9fMtCkV6eLhcNv7iY0fYxQI_ES1WbAqedOX0C5gCazH2HeqmoI_O68uwtIKndSHNMorNXM36x08aVpQMK',
			:client_secret  => '8570536555558642321'

		activity = {
			Duration__c: @user.fitness_activities.items.first.duration,
			Total_Distance__c: @user.fitness_activities.items.first.total_distance,
			Entry_Mode__c: @user.fitness_activities.items.first.entry_mode,
			Source__c: @user.fitness_activities.items.first.source,
			Start_Time__c: DateTime.strptime(@user.fitness_activities.items.first.start_time, format='%a, %d %b %Y %H:%M:%S').iso8601,
			Total_Calories__c: @user.fitness_activities.items.first.total_calories,
			Type__c: @user.fitness_activities.items.first.type,
			URI__c: @user.fitness_activities.items.first.uri.split('/').last,
			Activity__c: @fit.activity,
			Climb__c: @fit.climb,
			Equipment__c: @fit.equipment,
			Share__c: @fit.share
		}


		# Restforce.log = true
		if @client.upsert('Run_Keeper_Activity__c', 'URI__c', activity)
			activity = @client.find('Run_Keeper_Activity__c', @user.fitness_activities.items.first.uri.split('/').last, 'URI__c')

			ap activity

			#<HealthGraph::FitnessActivity::Path:0x0000010144d1b0 @timestamp=0, @altitude=135, @longitude=-78.815301, @latitude=35.923459, @type="start">
			@fit.paths.each do |path|
				@client.upsert('Run_Keeper_Path__c', 'Upsert_Checksum__c', {
												 altitude__c: path.altitude ,
												 latlng__longitude__s: path.longitude,
												 latlng__latitude__s: path.latitude,
												 RK_Activity__c: activity.Id,
												 Timestamp__c: path.timestamp,
												 type__c: path.type,
												 Upsert_Checksum__c: Digest::MD5.hexdigest(path.to_json)
				})
			end
		end
	end

	def authorize
		redirect_to @auth_url.to_s
	end

	def authenticate
		access_token = HealthGraph.access_token(params['authorization_code'])
		authtoken = Rk.last
		authtoken.authtoken = access_token unless authtoken.nil?
		Rk.create(authtoken: access_token) if authtoken.nil?

		redirect_to action: 'index'
	end

	def callback
		@authorization_code = params['code']
		redirect_to action: 'authenticate', authorization_code: @authorization_code
	end

	def setup_health_graph
		@hg = HealthGraph.configure do |config|
			config.client_id = '0a9b16d127b54773b6fa4d2f37589833'
			config.client_secret = '10c99797e07d4a099240d4f732f96279'
			config.authorization_redirect_url = 'http://localhost:3000/runkeeper/callback'
		end

		@auth_url = HealthGraph.authorize_url
	end

end
