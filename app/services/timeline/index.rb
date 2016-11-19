module Timeline
  class Index

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
      @per_page = (page[:size] || 25).to_i
      @page = (page[:number] || 1).to_i
      @user_id = params[:user_id]
    end

    def generate_result!
      followed = Relationship.where(follower_id: user_id).map do |r| r.followed_id end
      cards = Timeline::Card
              .where("(user_id IN (?) and card_type = ?) OR (user_id = ? and card_type = ?) OR user_id IS NULL", followed, Timeline::Card::USER_PRODUCT_TYPE, user_id, Timeline::Card::USER_LIKES_TYPE)
              .order(created_at: :desc)
              .page(page).per(per_page)
        self.success_result = cards
    end
  end
end
