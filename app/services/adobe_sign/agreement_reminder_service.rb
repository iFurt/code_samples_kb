module AdobeSign
  class AgreementReminderService < BaseService
    STATUS = 'ACTIVE'.freeze

    def perform
      return unless agreement.sent_for_sign?

      url = "/api/rest/v6/agreements/#{agreement.adobe_sign_agreement_id}/reminders"
      outputs = request(url, body.to_json, headers: { 'Content-Type' => 'application/json' })
      json_outputs = JSON.parse(outputs.body)

      unless outputs.success?
        raise "Adobe Sign error: #{json_outputs}"
      end

      agreement.publish_activity(:reminder_sent)

      json_outputs
    end

    private

    def body
      {
        recipientParticipantIds: awaiting_sign_member_ids,
        status: STATUS
      }
    end

    def members
      AdobeSign::AgreementGetMembersService.perform(agreement)
    end

    def awaiting_sign_member_ids
      members.select { |e| e[:is_current_signer] }.map { |e| e[:adobe_id] }
    end
  end
end
