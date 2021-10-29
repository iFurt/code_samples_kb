module AdobeSign
  class CreateTransientDocumentService < BaseService
    URL = 'transientDocuments'

    def perform
      outputs = request(URL, body)
      json_outputs = JSON.parse(outputs.body)

      if outputs.success?
        agreement.update(adobe_sign_transient_document_id: json_outputs['transientDocumentId'])
      else
        raise "Adobe Sign error: #{json_outputs}"
      end
    end

    private

    def body
      {
        'File' => Faraday::UploadIO.new(open(agreement.file.url), 'application/pdf'),
        'File-Name' => agreement.name
      }
    end
  end
end
