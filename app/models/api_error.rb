class ApiError

  FAILED_VALIDATION = 100

  attr_accessor :code, :detail, :title

  def self.title_for_error(error)
    case error
    when FAILED_VALIDATION then 'failed-validation'
    end
  end

  def initialize(params = {})
    @code = params.fetch(:code)
    @title = params.fetch(:title)
    @detail = params.fetch(:detail)
  end

  def to_json
    { code: code, detail: detail, title: title }.to_json
  end
end
