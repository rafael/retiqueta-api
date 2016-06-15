class BankAccount < ActiveRecord::Base
  VALID_ACCOUNT_TYPES = %w(checking savings)
  # VALID_DOCUMENT_ID_TYPES = %w(ci rif passport)

  belongs_to :profile

  #################
  ## Validations ##
  #################

  validates :profile, :document_type, :document_id, :owner_name,
            :bank_name, :account_type, :account_number, presence: true,
                                                        strict: ApiError::FailedValidation

  validate :valid_account_type
  # validate :valid_document_type

  private

  def valid_account_type
    unless VALID_ACCOUNT_TYPES.include?(account_type)
      fail ApiError::FailedValidation, I18n.t('profiles.errors.bank_account.invalid_type',
                                              valid_types: VALID_ACCOUNT_TYPES.join(', '))
    end
  end

  def valid_document_type
    unless VALID_DOCUMENT_ID_TYPES.include?(document_type)
      fail ApiError::FailedValidation,
           I18n.t('profiles.errors.bank_account.invalid_document_id_type',
                  valid_types: VALID_DOCUMENT_ID_TYPES.join(', '))
    end
  end
end
