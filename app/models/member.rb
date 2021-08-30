require 'open-uri'
class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, #, :registerable,
         :recoverable, :rememberable, :validatable

  has_shortened_urls
  validates :password_confirmation, :url, presence: true
  
  has_many :topics
  has_many :Friendships
  has_many :friends, through: :Friendships

  # validate :url_format
  after_create :generate_url_topics

  attr_reader :short_url, :unique_key

  def self.get_original_url(unique_key: )
    Shortener::ShortenedUrl.where(unique_key: unique_key).first.url
  end

  def url_format
    uri = URI.parse(url || "")
    if uri.host.nil?
      errors.add(:url, "Invalid URL format")
    end
  end

  def unique_key
    Shortener::ShortenedUrl.generate(url, owner: self).unique_key
  end

  def short_url
    "http://localhost:3000/s/#{unique_key}"
  end


  def full_name
    first_name+" "+last_name
  end

  private

  def generate_url_topics
    url_topics = get_url_topics
    url_topics.each do |url_topic|
      Topic.create(member_id: self.id, title: url_topic)
    end
  end

  def get_url_topics
    doc = Nokogiri::HTML(open(self.url))
    doc.css("h1, h2, h3").map(&:text) # {|e| e.text}
  end

end
