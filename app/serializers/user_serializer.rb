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
             :followers_count

  attribute :uuid, key: :id

  def profile_pic
    case options[:image_size]
    when "small" then object.pic.url(:small)
    when "large" then object.pic.url(:large)
    else object.pic.url
    end
  end
end
