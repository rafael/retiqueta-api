module Users
  class Following

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :valid_user

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = self.new(params)
      service.generate_result!
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :id, :current_user, :success_result, :per_page, :page

    def initialize(params = {})
      @id = params.fetch(:user_id)
      @current_user = params[:current_user]
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
    end

    def generate_result!
      following = user.following.page(page).per(per_page)
      self.success_result = following
    end

    private

    def user
      @user ||= User.find_by_uuid(id)
    end

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end
  end
end
