# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id            :integer          not null, primary key
#  token         :text             not null
#  refresh_token :string(255)      not null
#  expires_at    :datetime         not null
#  user_id       :integer
#  type          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class OauthAccessToken < ActiveRecord::Base
  belongs_to :user

  validates :type, uniqueness: true, unless: :user_id

  scope :shared, -> { where(user_id: nil) }

  def expired?
    expires_at.past?
  end

  def refresh_token!
    raise 'Not implemented'
  end

  private

  def connection
    @connection ||= Faraday.new(url: oauth_host)
  end

  def form_urlencoded_request(url, body, auth_header = nil)
    connection.post do |req|
      req.url url
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.headers['Authorization'] = auth_header if auth_header.present?
      req.body = URI.encode_www_form(body)
    end
  end

  def oauth_host
    raise 'Not implemented'
  end
end
