require 'sinatra'
require 'httparty'
require 'date'
require 'sendgrid-ruby'

require './notifier'

include SendGrid

helpers do
	def send_reminder members, urgency		
		from = Email.new(email: 'betaGouvBot@beta.gouv.fr')
		subject = 'Rappel: arrivée à échéance de contrats!'
		to = Email.new(email: 'contact@beta.gouv.fr')
		content = Content.new(type: 'text/plain', value: "Les contrats de #{members.join(',')} arrivent à échéance #{urgency}\n\n-- BetaGouvBot")
		mail = Mail.new(from, subject, to, content)

		sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
		response = sg.client.mail._('send').post(request_body: mail.to_json)
		# Log results for debugging
		puts response.status_code
		puts response.body
		puts response.headers
	end
end

post '/payload' do
	# Read beta.gouv.fr members API
	response = HTTParty.get('https://beta.gouv.fr/api/v1/authors.json')
	# Parse into a schedule of notifications
	today = Date.today
	members = response.parsed_response
	schedule = notifications(members,today)
	send_reminder schedule[:tomorrow], "demain" if schedule[:tomorrow]
	send_reminder schedule[:soon], "dans 10 jours" if schedule[:soon]
end
