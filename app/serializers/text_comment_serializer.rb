class TextCommentSerializer < ActiveModel::Serializer
  type 'text_comments'

  attributes :id, :text, :user_id, :user_pic

  def id
    object.uuid
  end

  def text
    JSON.parse(object.data)["attributes"]["text"]
  end
end
