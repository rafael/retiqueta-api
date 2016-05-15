class PayoutSerializer < ActiveModel::Serializer
  attributes :amount, :status, :id, :created_at

  def id
    object.uuid
  end

  def created_at
    I18n.l(object.created_at.to_date, format: :default)
  end
end
