module Products
  class Timeline
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

    attr_accessor :success_result, :per_page, :page, :user_id

    def initialize(params = {})
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
      @user_id = params[:user_id]
    end

    def generate_result!
      products = Product
                 .where(user_id: user.following_ids)
                 .order(created_at: :desc)
                 .page(page)
                 .per(per_page)
      self.success_result = products
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def valid_user
      return if user
      fail ApiError::NotFound, I18n.t('user.errors.not_found')
    end
  end
end
