module AdobeSign
  class DownloadSignedAgreementService < BaseService

    def perform
      url = "/api/rest/v6/agreements/#{agreement.adobe_sign_agreement_id}/combinedDocument"
      outputs = request(url)

      tempfile = save_to_tempfile(outputs)
      begin
        agreement.adobe_sign_agreement_file = tempfile
        agreement.save!
      ensure
        tempfile.close
        tempfile.unlink
      end
    end

    private

    def request(url)
      connection.get do |req|
        req.url url
        req.headers['Authorization'] = "Bearer #{access_token}"
      end
    end

    def save_to_tempfile(outputs)
      tempfile = Tempfile.new("agreement-#{agreement.id}.pdf", Rails.root.join('tmp'))
      tempfile.binmode
      tempfile.write outputs.body
      tempfile
    end
  end
end
