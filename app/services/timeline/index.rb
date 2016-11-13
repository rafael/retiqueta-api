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
      @per_page = page[:size].to_i || 25
      @page = page[:number].to_i || 1
      @user_id = params[:user_id]
    end

    def generate_result!
      cards = Timeline::Card
              .where(user_id: nil)
              .order(created_at: :desc)
              .page(page).per(per_page)
      if page == 1
        self.success_result = [user_likes_cards[0],
                               cards[0..1],
                               user_likes_cards[1],
                               cards[2..3],
                               user_likes_cards[2],
                               cards[4..-1]].compact.flatten
      else
        self.success_result = cards
      end

    end

    private

    def user_likes_cards
      @user_likes_cards ||=
        Timeline::Card
        .where(user_id: user_id)
        .where(card_type: Timeline::Card::USER_LIKES_TYPE)
        .order(created_at: :desc)
    end
  end
end
