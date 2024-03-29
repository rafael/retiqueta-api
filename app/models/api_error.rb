module ApiError
  class BaseError < StandardError
    def status
      fail NotImplementedError "Each error needs to provide it's status"
    end

    def title
      fail NotImplementedError "Each error needs to provide it's title"
    end

    def code
      fail NotImplementedError "Each error needs to provide it's code"
    end

    def to_json(*)
      { code: code, detail: message, title: title, status: status }.to_json
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
      'failed-validation'
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
      'unauthorized'
    end
  end

  class NotFound < BaseError
    def code
      102
    end

    def status
      404
    end

    def title
      'not-found'
    end
  end

  class InternalServer < BaseError
    def code
      103
    end

    def status
      500
    end

    def title
      'internal-error'
    end
  end
end
