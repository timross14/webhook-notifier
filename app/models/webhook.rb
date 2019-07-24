class UrlValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:url] << "must be a valid url" unless url_valid?(record.url)
  end

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end

class Webhook < ApplicationRecord
  include ActiveModel::Validations

  has_many :webhook_events

  validates_presence_of :name
  validates_presence_of :url, url: true
  validates_presence_of :zip_code
  validates :name,

            :inclusion  => { :in => [ 'watch', 'warning'] }
  validates_with UrlValidator
end

