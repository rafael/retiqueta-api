module Sales
  class Index
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

    attr_accessor :per_page, :page, :user_id

    def initialize(params = {})
      @user_id = params.fetch(:user_id)
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
    end

    def generate_result!
      Sale
        .where(user_id: user_id)
        .order(created_at: :desc)
        .page(page)
        .per(per_page)
    end
  end
end
