require './notifier'
require 'date'

RSpec.describe "generating notifications:" do

	context "when member list is empty" do
		it "generates no notification" do
			members = []
			date = Date.parse('2016-10-12')
			expect(notifications(members,date)).to eq ({})
		end
	end

	context "when one member has end date tomorrow" do
		it "generates a 'tomorrow' notification" do
			members = [{fullname: "lbo",end: "2016-12-01"}]
			date = Date.parse('2016-11-30')
			expect(notifications(members,date)).to eq ({tomorrow: ["lbo"]})
		end
	end

	context "when two members have an end date tomorrow" do
		it "generates one 'tomorrow' notification" do
			members = [{fullname: "lbo",end: "2016-12-01"},{fullname: "you",end: "2016-12-01"}]
			date = Date.parse('2016-11-30')
			expect(notifications(members,date)).to eq ({tomorrow:["lbo","you"]})
		end
	end

	context "when one member has end date in ten days" do
		it "generates a 'soon' notification" do
			members = [{fullname: "lbo",end: "2016-12-10"}]
			date = Date.parse('2016-11-30')
			expect(notifications(members,date)).to eq ({soon:["lbo"]})
		end
	end

	context "when members have end dates with both cases" do
		it "generates one 'tomorrow' notification" do
			members = [{fullname: "lbo",end: "2016-12-10"},{fullname: "you",end: "2016-12-01"}]
			date = Date.parse('2016-11-30')
			expect(notifications(members,date)).to eq ({tomorrow:["you"],soon:["lbo"]})
		end
	end

	context "when members have no end date" do
		it "generates no notifications" do
			members = [{fullname: "lbo"},{fullname: "you",end: ""}]
			date = Date.parse('2016-10-12')
			expect(notifications(members,date)).to eq ({})
		end
	end

	context "when members have end date already past" do
		it "generates no notifications" do
			members = [{fullname: "lbo",end: "2016-10-30"},{fullname: "you",end: ""}]
			date = Date.parse('2016-10-12')
			expect(notifications(members,date)).to eq ({})
		end
	end

	context "when hashes are keyed with strings" do
		it "does its thing anyway" do
			members = [{"fullname" => "lbo", "end" => "2016-12-01"}]
			date = Date.parse('2016-11-30')
			expect(notifications(members,date)).to eq ({tomorrow:["lbo"]})
		end
	end
end
