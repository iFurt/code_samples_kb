# == Schema Information
#
# Table name: proposals
#
#  id                          :integer          not null, primary key
#  organization_id             :integer          not null
#  user_id                     :integer          not null
#  name                        :string(255)
#  status                      :string(255)      not null
#  issue_date                  :date             not null
#  expiry_date                 :date
#  sub_total                   :decimal(30, 10)  default(0.0), not null
#  discount_value              :decimal(30, 10)  default(0.0), not null
#  total_tax                   :decimal(30, 10)  default(0.0), not null
#  total                       :decimal(30, 10)  default(0.0), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  discount_type               :string(255)
#  file                        :string(255)
#  type                        :string(255)      not null
#  quotation_id                :integer
#  start_date                  :date
#  initial_term                :integer
#  recipients                  :text
#  address_id                  :integer
#  address_type                :string(255)
#  faria_rep_user_id           :integer
#  school_rep_contact_email_id :integer
#
# Foreign Keys
#
#  fk_rails_a3d58a706c  (quotation_id => proposals.id)
#  fk_rails_e699ecdeef  (organization_id => contacts.id)
#  fk_rails_f63036eec2  (user_id => users.id)
#

class Agreement < Proposal
  include AASM

  belongs_to :quotation
  belongs_to :faria_rep_user, class_name: 'User'
  belongs_to :school_rep_contact_email, class_name: 'ContactEmail'
  has_one :school_rep_contact, class_name: 'Person', through: :school_rep_contact_email, source: :contact

  def link_to_signed_inside_adobe
    [
      "https://secure.#{ENV['ADOBE_SIGN_SHARD_NAME']}.echosign.com",
      'public',
      'agreements',
      'view',
      adobe_sign_agreement_id
    ].join('/')
  end

  private

  def send_via_adobe_sign(current_user)
    raise 'Document already exists' if adobe_sign_agreement_id.present?

    post_transient_document if adobe_sign_transient_document_id.blank?
    send_agreement(current_user)
  end

  def cancel_adobe_sign_agreement
    return if adobe_sign_agreement_id.blank?

    cancel_agreement
  end

  def post_transient_document
    AdobeSign::CreateTransientDocumentService.perform(self)
  end

  def send_agreement(current_user)
    AdobeSign::SendDocumentService.perform(self, current_user)
  end

  def cancel_agreement
    AdobeSign::AgreementCancelService.perform(self)
    update(adobe_sign_agreement_id: nil, adobe_sign_transient_document_id: nil)
  end

  def update_name
    update(name: "AGR-#{quotation_id + Quotation::OFFSET}") if name.nil?
  end
end
