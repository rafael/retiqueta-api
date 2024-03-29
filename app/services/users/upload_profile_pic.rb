require 'rack/mime'

module Users
  class UploadProfilePic

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :type_is_users
    validates :data, :attributes, :pic, :content, :content_type, :filename, presence: true, strict: ApiError::FailedValidation

    ###################
    ## Class Methods ##
    ###################

    RESOURCE_TYPE = "users"

    def self.call(params = {})
      service = self.new(params)
      service.generate_result! if service.valid?
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result, :id, :type, :data, :attributes, :pic, :content, :content_type, :filename, :user, :tempfile

    def initialize(params = {})
      @id = params.fetch(:id)
      @data = params[:data]
      @attributes = data[:attributes] if data
      @pic = attributes[:pic] if attributes
      @content = pic[:content] if pic
      @filename = pic[:filename] if pic
      @content_type = pic[:content_type] if pic
      @type = data[:type]
      valid?
    end

    def valid?
      errors.empty? && super
    end

    def generate_result!
      user = User.find_by_uuid(id)
      raise ApiError::NotFound.new(I18n.t("user.errors.not_found")) unless user
      begin
        pic = parse_image_data
        user.profile.pic = pic
        user.profile.save!
        self.success_result = user
      rescue => e
        Rails.logger.error e.message
        raise ApiError::InternalServer.new("Failed to persist image.")
      end
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
        filename: "#{SecureRandom.uuid}#{Rack::Mime::MIME_TYPES.invert[content_type]}"
      )
      uploaded_file.content_type = content_type
      uploaded_file
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end
  end
end
