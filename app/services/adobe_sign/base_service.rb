class AdobeSign::BaseService
  ADOBE_SIGN_HOST = "https://api.#{ENV['ADOBE_SIGN_SHARD_NAME']}.echosign.com/api/rest/v6/"
  WEBHOOK_LAG = 10.seconds

  attr_reader :agreement, :current_user, :adobe_sign_oauth_access_token

  def self.perform(*args)
    new(*args).perform
  end

  def initialize(agreement, current_user = nil)
    @agreement = agreement.decorate
    @current_user = current_user
    @adobe_sign_oauth_access_token = AdobeSignOauthAccessToken.take!
  end

  private

  def connection
    @connection ||= Faraday.new(url: ADOBE_SIGN_HOST) do |f|
      f.request :multipart
      f.request :url_encoded
      f.adapter :net_http
    end
  end

  def request(url, body = nil, headers: {})
    connection.post do |req|
      req.url url
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers.merge!(headers)
      req.body = body
    end
  end

  def access_token
    @access_token ||= begin
      adobe_sign_oauth_access_token.refresh_token!
      adobe_sign_oauth_access_token.token
    end
  end
end
