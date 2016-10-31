class ProductsIndexer < ActiveJob::Base

  queue_as :indexer

  def client
    @client ||= Elasticsearch::Client.new(host: Rails.configuration.x.elastictsearch.host,
                                          log: true)
  end

  def perform(id, operation)
    case operation.to_s
    when /index/
      record = Product.find_by_id(id)
      if record
        client.index(index: Product.__elasticsearch__.index_name,
                     type: Product.__elasticsearch__.document_type,
                     id: record.id,
                     body: record.as_indexed_json)
      else
        raise ArgumentError, "Asked to index unexistent product: #{id}"
      end
    when /delete/
      client.delete(index: Product.__elasticsearch__.index_name,
                    type: Product.__elasticsearch__.document_type,
                    id: id)
    else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
