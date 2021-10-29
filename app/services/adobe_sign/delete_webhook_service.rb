module AdobeSign
  class DeleteWebhookService < BaseService

    def perform
      url = "webhooks/#{agreement.adobe_sign_webhook_id}"
      outputs = request(url)

      unless outputs.success?
        raise "Adobe Sign error: #{outputs.body}"
      end

      agreement.update(adobe_sign_webhook_id: nil)
    end

    private

    def request(url)
      connection.delete do |req|
        req.url url
        req.headers['Authorization'] = "Bearer #{access_token}"
      end
    end
  end
end
