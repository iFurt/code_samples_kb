module AdobeSign
  class CreateWebhookService < BaseService
    URL = 'webhooks'.freeze
    EVENTS = ['AGREEMENT_ALL'].freeze
    SCOPE = 'RESOURCE'.freeze
    STATE = 'ACTIVE'.freeze
    RESOURCE_TYPE = 'AGREEMENT'.freeze

    def perform
      outputs = request(URL, body.to_json, headers: { 'Content-Type' => 'application/json' })
      json_outputs = JSON.parse(outputs.body)

      unless outputs.success?
        raise "Adobe Sign error: #{json_outputs}"
      end

      agreement.update(adobe_sign_webhook_id: json_outputs['id'])
    end

    private

    def body
      {
        name: "Webhook for agreement ID #{agreement.id} (#{agreement.name})",
        scope: SCOPE,
        state: STATE,
        webhookSubscriptionEvents: EVENTS,
        resourceId: agreement.adobe_sign_agreement_id,
        resourceType: RESOURCE_TYPE,
        webhookUrlInfo: {
          url: ENV['ADOBE_SIGN_WEBHOOK_URI']
        }
      }
    end
  end
end
