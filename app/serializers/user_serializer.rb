class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :profile_pic

  attribute :uuid, key: :id

  def profile_pic
    object.pic.url(:medium)
  end
end
