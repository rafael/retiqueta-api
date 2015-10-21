module ApiError
  class BaseError < StandardError

    def status
      raise NotImplementedError "Each error needs to provide it's status"
    end

    def title
      raise NotImplementedError "Each error needs to provide it's title"
    end

    def code
      raise NotImplementedError "Each error needs to provide it's code"
    end

    def to_json(*)
      { code: code, detail: message , title: title, status: status }.to_json
    end
  end

  class FailedValidation < BaseError
    def code
      100
    end

    def status
      400
    end

    def title
      "failed-validation"
    end
  end

  class Unauthorized < BaseError
    def code
      101
    end

    def status
      401
    end

    def title
      "unauthorized"
    end
  end
end
