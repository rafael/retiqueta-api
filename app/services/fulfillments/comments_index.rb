module Fulfillments
  class CommentsIndex

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

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

    attr_accessor :success_result, :fulfillment_id

    def initialize(params = {})
      @fulfillment_id = params.fetch(:fulfillment_id)
    end

    def generate_result!
      comments = fulfillment.comments
      self.success_result = comments
    end

    private

    def fulfillment
      @fulfillment ||= Fulfillment.find_by_uuid(fulfillment_id)
    end

    def valid_fulfillment
      unless fulfillment
        raise ApiError::NotFound.new(I18n.t("fulfillment.errors.not_found"))
      end
    end
  end
end
