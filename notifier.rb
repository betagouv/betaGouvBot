require 'date'
require 'active_support/core_ext/hash/indifferent_access'

def notifications members, date
	result = {}
	by_date = members.map(&:with_indifferent_access).group_by {|item| item[:end]}
	tomorrow = (date + 1).iso8601
	soon = (date + 10).iso8601
	result[:tomorrow] = by_date[tomorrow].map {|one| one[:fullname]} if by_date[tomorrow]
	result[:soon] = by_date[soon].map {|one| one[:fullname]} if by_date[soon]
	result
end
