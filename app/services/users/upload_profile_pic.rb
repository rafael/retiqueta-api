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
    validates :data, :attributes, presence: true

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

    attr_accessor :success_result, :failure_result, :id, :type, :data, :attributes, :pic, :user, :tempfile

    def initialize(params = {})
      @id = params.fetch(:id)
      @data = params[:data]
      @attributes = data[:attributes]
      @type = data[:type]
    end

    def valid?
      errors.empty? && super
    end

    def generate_result!
      return unless valid?
      user = User.find_by_uuid(id)
      return self.errors.add(:base, 'User not found') unless user
        pic = parse_image_data(attributes[:pic]) if attributes[:pic]
        user.profile.pic = pic
      if user.profile.save!
        self.success_result = user
      else
        self.errors.add(:base, 'ERROR TBD')
      end
    end

    def failure_result
      @failure_result ||= ApiError.new(title: ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                                       code: ApiError::FAILED_VALIDATION,
                                       detail: errors.full_messages.join(', '))
    end

    private

    def parse_image_data(image_data)
      tempfile = Tempfile.new("temp_image_#{SecureRandom.uuid}")
      tempfile.binmode
      tempfile.write Base64.decode64(image_data[:content])
      tempfile.rewind

      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: image_data[:filename]
      )
      uploaded_file.content_type = image_data[:content_type]
      uploaded_file
    end

    def clean_tempfile
      if tempfile
        tempfile.close
        tempfile.unlink
      end
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        self.errors.add(:type, "is invalid. Provied: #{type}, required #{RESOURCE_TYPE}")
      end
    end
  end
end
