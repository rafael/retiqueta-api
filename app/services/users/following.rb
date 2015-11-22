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

    attr_accessor :id, :current_user, :request_context, :success_result, :per_page, :page

    def initialize(params = {})
      @id = params.fetch(:user_id)
      @current_user = params[:current_user]
      @request_context = params[:request_context]
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
    end

    def generate_result!
      followers = user.following.page(page).per(per_page)
      followers_serializable_hash =
        ActiveModel::SerializableResource.new(followers,
                                              adapter: :json_api,
                                              context: request_context,
                                              each_serializer: FollowerSerializer).serializable_hash(context: request_context)
      followers_with_meta = followers_serializable_hash.inject({}) do |acc, (key, value)|
        if key == :data
          acc[key] = value.map do |follower|
            follower.merge(meta: {
                             followed_by_current_user: current_user && current_user.following?(User.find_by_uuid(follower[:id]))
                           })
          end
        else
          acc[key] = value
        end
        acc
      end
      self.success_result = followers_with_meta
    end

    private

    def user
      @user ||= User.find_by_uuid(id)
    end

    def valid_followed
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end
  end
end
