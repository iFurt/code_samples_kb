class AdobeSignController < ApplicationController
  before_action :verify_eligibility

  def send_agreement
    agreement.send_for_sign!(current_user)
    flash[:notice] = 'Agreement has been sent via Adobe Sign'
    redirect_to organization_agreement_path(organization_id: agreement.organization_id, id: agreement.id)
  end

  def send_agreement_reminder
    flash[:notice] = 'Reminder was sent via Adobe Sign'
    AgreementReminderWorker.perform_async(agreement.id)
    redirect_to organization_agreement_path(organization_id: agreement.organization_id, id: agreement.id)
  end

  private

  def verify_eligibility
    redirect_to root_path unless current_user.adobe_sign_permitted?
  end

  def agreement
    @agreement ||= Agreement.find(params[:id])
  end
end
