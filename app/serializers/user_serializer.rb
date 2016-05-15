class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :email,
             :profile_pic,
             :first_name,
             :last_name,
             :website,
             :country,
             :bio,
             :following_count,
             :followers_count,
             :currency,
             :bank_account,
             :available_balance

  def id
    object.uuid
  end

  def bank_account
    bank_account = object.bank_account
    if bank_account
      {
        document_type: bank_account.document_type,
        document_id: bank_account.document_id,
        owner_name: bank_account.owner_name,
        bank_name: bank_account.bank_name,
        account_type: bank_account.account_type,
        account_number: bank_account.account_number,
        country: bank_account.country
      }
    else
      nil
    end
  end

  def profile_pic
    case instance_options[:image_size]
    when "small" then object.pic.url(:small)
    when "large" then object.pic.url(:large)
    else object.pic.url
    end
  end

  def country
    code = object.country
    name =
      case code
      when "VE" then "Venezuela"
      else ""
      end

    { code: code, name: name }
  end

  def currency
    code, name, symbol = nil
    if object.country
      c = ISO3166::Country.new(object.country).currency
      code, name, symbol = c.code, c.name, c.symbol
    end

    { code: code, name: name, symbol: symbol }
  end
end
