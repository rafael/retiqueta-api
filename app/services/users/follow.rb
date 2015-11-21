module Users
  class Follow

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :valid_follower
    validate :valid_followed
    validate :not_following_itself

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = self.new(params)
      service.generate_result! if service.valid?
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :follower_id, :followed_id

    def initialize(params = {})
      @followed_id = params.fetch(:followed_id)
      @follower_id = params.fetch(:follower_id)
      valid?
    end

    def generate_result!
      follower.active_relationships.create!(followed_id: followed.uuid)
    rescue ActiveRecord::RecordNotUnique
      raise ApiError::FailedValidation.new(I18n.t("user.errors.already_following"))
    end

    private

    def followed
      @followed ||= User.find_by_uuid(followed_id)
    end

    def follower
      @follower ||= User.find_by_uuid(follower_id)
    end

    def valid_followed
      unless followed
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    def valid_follower
      unless follower
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    def not_following_itself
      unless follower != followed
        raise ApiError::FailedValidation.new(I18n.t("user.errors.following_itself_not_allowed"))
      end
    end
  end
end
