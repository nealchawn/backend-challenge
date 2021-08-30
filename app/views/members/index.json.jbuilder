json.array! @members do |member|
  json.name member.full_name
  json.short_url member.short_url
  json.total_friends member.friendships.count
end