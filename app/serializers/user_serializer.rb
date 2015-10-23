class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :email, :profile_pic

  attribute :uuid, key: :id

  def profile_pic
    object.profile.pic.url(:medium)
  end
end
