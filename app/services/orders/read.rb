module Orders
  class Read
    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :valid_user
    validate :valid_order

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
      order
    end

    private

    def order
      @order ||= Order.find_by_uuid(id)
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def valid_order
      if order.user_id != user.uuid && !order.sellers.map(&:uuid).include?(user.uuid)
        raise ApiError::NotFound, I18n.t("orders.errors.not_found")
      end
    end

    def valid_user
      raise ApiError::NotFound, I18n.t("user.errors.not_found") unless user
    end
  end
end
