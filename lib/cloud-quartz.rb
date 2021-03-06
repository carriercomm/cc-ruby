require 'httparty'
require 'json'

class CloudQuartz
	include HTTParty
	@api_key = ""
	@agent_id = ""
	
	def initialize(options = {})
		@api_key = options[:api_key]
		@agent_id = options[:agent_id]
		@secret_key = options[:secret_key]
		self.class.base_uri options[:url] || 'https://api.cloud66.com'
	end

	def get_job
		process(self.class.get("/queue/#{@agent_id}.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key) } ))
	end

	def register(agent)
		process(self.class.post('/agent.json', { :headers => ClientAuth.build_headers(@api_key, @secret_key).merge({'Content-Type' => 'application/json'}), :body => agent.to_json }))
	end

	def unregister(agent)
		process(self.class.delete("/agent/#{@agent_id}.json", :headers => ClientAuth.build_headers(@api_key, @secret_key)))
	end

	def post_results(job_id, data)
		process(self.class.post("/job/#{job_id}/complete.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key).merge({'Content-Type' => 'application/json'}), :body => data.to_json } ))
	end

	def pulse_without_ip_address
		process(self.class.get("/agent/#{@agent_id}/pulse.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key) } ))
	end

	def pulse_with_ip_address(data)
		process(self.class.post("/agent/#{@agent_id}/pulse.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key).merge({'Content-Type' => 'application/json'}), :body => data.to_json } ))
	end

	def status(stat)
		data = { :status => stat }
		process(self.class.post("/agent/#{@agent_id}/status.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key).merge({'Content-Type' => 'application/json'}), :body => data.to_json }))
	end

	def init(data)
		process(self.class.post("/agent/#{@agent_id}/initialize.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key).merge({'Content-Type' => 'application/json'}), :body => data.to_json }))
	end

	def send_vital_signs(data)
		process(self.class.post("/agent/#{@agent_id}/vitalsigns.json", { :headers => ClientAuth.build_headers(@api_key, @secret_key).merge({'Content-Type' => 'application/json'}), :body => data.to_json } ))
	end

	private

	def process(response)
		if response.code != 200
			raise response.body
		else
			response.parsed_response
		end
	end
end


