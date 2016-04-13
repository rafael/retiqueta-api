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
             :currency

  def id
    object.uuid
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
