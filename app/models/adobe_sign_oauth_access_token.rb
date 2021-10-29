class AdobeSignOauthAccessToken < OauthAccessToken
  SCOPE = 'agreement_read+agreement_write+agreement_send+webhook_read+webhook_write+webhook_retention'

  def self.access_token_link
    "https://secure.#{ENV['ADOBE_SIGN_SHARD_NAME']}.echosign.com/public/oauth?redirect_uri=#{ENV['ADOBE_SIGN_REDIRECT_URI']}&response_type=code&client_id=#{ENV['ADOBE_SIGN_CLIENT_ID']}&scope=#{SCOPE}"
  end

  def retreive_token!(code)
    data = {
      code: code,
      grant_type: 'authorization_code',
      client_id: ENV['ADOBE_SIGN_CLIENT_ID'],
      client_secret: ENV['ADOBE_SIGN_SECRET'],
      redirect_uri: ENV['ADOBE_SIGN_REDIRECT_URI']
    }

    outputs = form_urlencoded_request('token', data)

    raise "Adobe Sign Auth error: #{outputs.body}" unless outputs.success?

    json_outputs = JSON.parse(outputs.body)
    self.token = json_outputs['access_token']
    self.refresh_token = json_outputs['refresh_token']
    self.expires_at = Time.now + json_outputs['expires_in'].to_i
    save!
  end

  def refresh_token!
    return if refresh_token.blank? || !expired?

    data = {
      refresh_token: refresh_token,
      grant_type: 'refresh_token',
      client_id: ENV['ADOBE_SIGN_CLIENT_ID'],
      client_secret: ENV['ADOBE_SIGN_SECRET']
    }

    outputs = form_urlencoded_request('refresh', data)

    raise "Adobe Sign Auth error: #{outputs.body}" unless outputs.success?

    json_outputs = JSON.parse(outputs.body)
    self.token = json_outputs['access_token']
    self.expires_at = Time.now + json_outputs['expires_in'].to_i
    save!
  end

  private

  def oauth_host
    @oauth_host ||= "https://api.#{ENV['ADOBE_SIGN_SHARD_NAME']}.echosign.com/oauth"
  end
end
