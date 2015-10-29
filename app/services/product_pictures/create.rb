module ProductPictures
  class Create

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :type_is_valid
    validates :data, :attributes, :pic, :content, :content_type, :filename, :position, presence: true, strict: ApiError::FailedValidation

    ###################
    ## Class Methods ##
    ###################

    RESOURCE_TYPE = "product_pictures"

    def self.call(params = {})
      service = self.new(params)
      service.generate_result! if service.valid?
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result, :user_id, :type, :data, :attributes, :pic, :content, :content_type, :filename, :position, :user, :tempfile

    def initialize(params = {})
      @user_id = params.fetch(:user_id)
      @data = params[:data]
      @attributes = data[:attributes] if data
      @position = attributes[:position] if attributes
      @pic = attributes[:pic] if attributes
      @content = pic[:content] if pic
      @filename = pic[:filename] if pic
      @content_type = pic[:content_type] if pic
      @type = data[:type]
      valid?
    end

    def generate_result!
      user = User.find_by_uuid(user_id)
      raise ApiError::NotFound.new(I18n.t("user.errors.not_found")) unless user
      pic = parse_image_data
      product_picture = ProductPicture.new(user: user, position: position)
      product_picture.pic = pic
      product_picture.save!
      self.success_result = product_picture
    rescue => e
      Rails.logger.error e.message
      raise ApiError::InternalServer.new("Failed to persist image.")
    ensure
      if @tempfile
        @tempfile.close
        @tempfile.unlink
      end
    end

    private

    def parse_image_data
      @tempfile = Tempfile.new("temp_image_#{SecureRandom.uuid}")
      @tempfile.binmode
      @tempfile.write Base64.decode64(content)
      @tempfile.rewind

      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: @tempfile,
        filename: filename
      )
      uploaded_file.content_type = content_type
      uploaded_file
    end

    def type_is_valid
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end
  end
end
