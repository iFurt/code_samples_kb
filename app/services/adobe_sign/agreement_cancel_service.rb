module AdobeSign
  class AgreementCancelService < BaseService
    CANCEL_STATUS = 'CANCELLED'.freeze

    def perform
      return unless agreement.sent_for_sign?

      url = "/api/rest/v6/agreements/#{agreement.adobe_sign_agreement_id}/state"
      outputs = request(url, body.to_json, headers: { 'Content-Type' => 'application/json' })

      unless outputs.success?
        raise "Adobe Sign error: #{outputs.body}"
      end

      DeleteAdobeSignWebhookWorker.perform_in(WEBHOOK_LAG, agreement.id)
      true
    end

    private

    def body
      {
        state: CANCEL_STATUS
      }
    end

    def request(url, body = nil, headers: {})
      connection.put do |req|
        req.url url
        req.headers['Authorization'] = "Bearer #{access_token}"
        req.headers.merge!(headers)
        req.body = body
      end
    end
  end
end
