class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, #, :registerable,
         :recoverable, :rememberable, :validatable

  has_shortened_urls
  validates :password_confirmation, :url, presence: true
  validate :url_format

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
end
