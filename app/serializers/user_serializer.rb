class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :email, :profile_pic, :dob

  attribute :uuid, key: :id

  def profile_pic
    object.profile.pic.url(:medium)
  end

  def dob
    "2015-01-11"
  end
end
