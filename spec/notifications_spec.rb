require './notifier'
require 'date'

RSpec.describe "generating notifications:" do
	context "when there are no previous notifications" do

			context "when member list is empty" do
				it "generates no notification" do
					members = []
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq []
				end
			end

	end
end
