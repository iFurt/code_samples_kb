module AdobeSign
  class AgreementGetMembersService < BaseService
    CURRENT_SIGNER_STATUS = 'WAITING_FOR_MY_SIGNATURE'.freeze

  	def perform
      url = "/api/rest/v6/agreements/#{agreement.adobe_sign_agreement_id}/members"
      outputs = request(url)
      json_outputs = JSON.parse(outputs.body)

      unless outputs.success?
        raise "Adobe Sign error: #{json_outputs}"
      end

      json_outputs['participantSets'].map do |e|
        member_info = e['memberInfos'].first
        {
          adobe_id: member_info['id'],
          email: member_info['email'],
          is_current_signer: e['status'] == CURRENT_SIGNER_STATUS
        }
      end
    end

    private

    def request(url)
      connection.get do |req|
        req.url url
        req.headers['Authorization'] = "Bearer #{access_token}"
      end
    end
  end
end
