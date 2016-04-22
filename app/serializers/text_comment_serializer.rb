class TextCommentSerializer < ActiveModel::Serializer
  type 'text_comments'

  attributes :id, :text, :user_id, :user_pic, :username

  def id
    object.uuid
  end

  def username
    object.user.username
  end

  def text
    JSON.parse(object.data)["attributes"]["text"]
  end
end
