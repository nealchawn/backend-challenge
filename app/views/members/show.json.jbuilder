json.name @member.full_name
json.url @member.url
json.short_url @member.short_url
json.topics @member.topics.map(&:title)
json.friends_urls @member.friends.map {|friend| url_for(@member, friend)}
json.friends @member.friends