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

			context "when one member has a future end date" do
				it "generates two notifications" do
					members = [{id: "author/lbo",end: "2016-12-01"}]
					date = Date.parse('2016-12-01')
					expect(notifications(members,date)).to eq [{when:"2016-11-21",who:["author/lbo"]},{when:"2016-11-30",who:["author/lbo"]}]
				end
			end

			context "when two members have a future end date" do
				it "generates four notifications" do
					members = [{id: "author/lbo",end: "2016-12-01"},{id: "author/you",end: "2016-12-02"}]
					date = Date.parse('2016-12-01')
					expect(notifications(members,date)).to eq [{when:"2016-11-21",who:["author/lbo"]},{when:"2016-11-30",who:["author/lbo"]},
					  {when:"2016-11-22",who:["author/you"]},{when:"2016-12-01",who:["author/you"]}]
				end
			end
	end
end
