module Sales
  class Read
    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :valid_user
    validate :valid_sale

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = new(params)
      service.generate_result!
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :id, :user_id

    def initialize(params = {})
      @user_id = params.fetch(:user_id)
      @id = params.fetch(:id)
      valid?
    end

    def generate_result!
      sale
    end

    private

    def sale
      @sale ||= Sale.find_by_uuid(id)
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def valid_sale
      if sale.user_id != user.uuid
        raise ApiError::NotFound, I18n.t("sales.errors.not_found")
      end
    end

    def valid_user
      raise ApiError::NotFound, I18n.t("user.errors.not_found") unless user
    end
  end
end
