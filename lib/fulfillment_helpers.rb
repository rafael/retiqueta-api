module FulfillmentHelpers
  def fulfillment_order(fulfillment)
    @fulfillment_order ||= fulfillment.order
  end

  def buyer(order)
    @buyer ||= order.user
  end

  def seller(order)
    @seller ||= product_order(order).user
  end

  def product_order(order)
    @product_order ||= order.line_items.first.product
  end
end
