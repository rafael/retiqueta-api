class CardSerializer  < SimpleDelegator

  def initialize(object, params)
    serializer = object.serializer
    serializer_instance = serializer.new(object.json_ast, params)
    __setobj__(serializer_instance)
  end

  def self._cache
    nil
  end

  def self._cache_only
    nil
  end
  def self._cache_except
    nil
  end
end
