module AdobeSign
  class SendDocumentService < BaseService
    URL = 'agreements'

    def perform
      outputs = request(URL, body.to_json, headers: { 'Content-Type' => 'application/json' })
      json_outputs = JSON.parse(outputs.body)

      if outputs.success?
        agreement.update(adobe_sign_agreement_id: json_outputs['id'])
        CreateAdobeSignWebhookWorker.perform_in(WEBHOOK_LAG, agreement.id)
      else
        raise "Adobe Sign error: #{json_outputs}"
      end
    end

    private

    def body
      {
        "fileInfos": [{
            "transientDocumentId": agreement.adobe_sign_transient_document_id
        }],
        "name": agreement.fancy_file_name,
        "participantSetsInfo": [{
            "memberInfos": [{
                "email": agreement.faria_rep_user.email
            }],
            "order": 1,
            "role": "SIGNER",
            "label": "signer1"
        },{
            "memberInfos": [{
                "email": agreement.school_rep_contact_email.email
            }],
            "order": 2,
            "role": "SIGNER",
            "label": "signer2"
        }],
        "ccs": [
          {
            "email": current_user&.email
          }
        ],
        "signatureType": "ESIGN",
        "state": "IN_PROCESS"
      }
    end
  end
end
