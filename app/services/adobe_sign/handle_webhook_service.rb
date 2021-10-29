module AdobeSign
  class HandleWebhookService
    WH_CANCELLED_STATUS = 'AGREEMENT_RECALLED'.freeze
    WH_WORKFLOW_COMPLETED_STATUS = 'AGREEMENT_WORKFLOW_COMPLETED'.freeze

    attr_reader :webhook_body

    def self.perform(*args)
      new(*args).perform
    end

    def initialize(webhook_body)
      @webhook_body = webhook_body
    end

    def perform
      status = webhook_body['adobe_sign']['event']
      agreement_adobe_id = webhook_body['adobe_sign']['agreement']['id']
      return unless status.in?([WH_CANCELLED_STATUS, WH_WORKFLOW_COMPLETED_STATUS])

      agreement = Agreement.find_by!(adobe_sign_agreement_id: agreement_adobe_id)
      return perform_agreement_sign(agreement) if status == WH_WORKFLOW_COMPLETED_STATUS
      return perform_agreement_cancel(agreement) if status == WH_CANCELLED_STATUS
    end

    private

    def perform_agreement_sign(agreement)
      DownloadSignedAgreementWorker.perform_async(agreement.id)
      agreement.sign!
    end

    def perform_agreement_cancel(agreement)
      agreement.decline!
    end
  end
end
