module Users
  class Read

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

    attr_accessor :success_result, :metadata, :id, :current_user_id

    def initialize(params = {})
      @id = params.fetch(:id)
      @current_user_id = params[:current_user_id]
    end

    def generate_result!
      if user
        self.success_result = user
        self.metadata = metadata_value
      else
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    private

    def user
      @user ||= User.find_by_uuid(id)
    end

    def current_user
      @current_user ||= User.find_by_uuid(current_user_id)
    end

    def metadata_value
      { followed_by_current_user: current_user && current_user.following?(user) }
    end
  end
end
