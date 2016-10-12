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
					members = [{fullname: "lbo",end: "2016-12-01"}]
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq [{when:"2016-11-21",who:["lbo"]},{when:"2016-11-30",who:["lbo"]}]
				end
			end

			context "when two members have a future end date" do
				it "generates four notifications" do
					members = [{fullname: "lbo",end: "2016-12-01"},{fullname: "you",end: "2016-12-02"}]
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq [{when:"2016-11-21",who:["lbo"]},{when:"2016-11-30",who:["lbo"]},
					  {when:"2016-11-22",who:["you"]},{when:"2016-12-01",who:["you"]}]
				end
			end

			context "when two members have the same end date" do
				it "generates two notifications" do
					members = [{fullname: "lbo",end: "2016-12-01"},{fullname: "you",end: "2016-12-01"}]
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq [{when:"2016-11-21",who:["lbo","you"]},
					  {when:"2016-11-30",who:["lbo","you"]}]
				end
			end

			context "when members have no end date" do
				it "generates no notifications" do
					members = [{fullname: "lbo"},{fullname: "you",end: ""}]
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq []
				end
			end

			context "when members have end date already past" do
				it "generates no notifications" do
					members = [{fullname: "lbo",end: "2016-09-30"},{fullname: "you",end: ""}]
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq []
				end
			end

			context "when hashes are keyed with strings" do
				it "does its thing anyway" do
					members = [{"fullname" => "lbo", "end" => "2016-12-01"}]
					date = Date.parse('2016-10-12')
					expect(notifications(members,date)).to eq [{when:"2016-11-21",who:["lbo"]},{when:"2016-11-30",who:["lbo"]}]
				end
			end
	end
end
