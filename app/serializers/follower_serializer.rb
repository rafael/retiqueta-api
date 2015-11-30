class FollowerSerializer < ActiveModel::Serializer
  attributes :username, :id

  def id
    object.uuid
  end

  meta do
    { followed_by_current_user: current_user && current_user.following?(object) }
  end
end
