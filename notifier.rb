require 'date'

def notifications members, date
	return [] if members.empty?
	item = members.first
	date = Date.parse item[:end]
	soon = (date - 10).iso8601
	late = (date - 1).iso8601
	[{when:soon, who:[item[:id]]},{when:late, who:[item[:id]]}]
end
