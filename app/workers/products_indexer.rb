class ProductsIndexer < ActiveJob::Base

  queue_as :indexer

  def client
    @client ||= Elasticsearch::Client.new(host: Rails.configuration.x.elastictsearch.host,
                                          log: true)
  end

  def perform(record, operation)
    case operation.to_s
    when /index/
      client.index(index: Product.__elasticsearch__.index_name,
                   type: Product.__elasticsearch__.document_type,
                   id: record.id,
                   body: record.as_indexed_json)
    when /delete/
      client.delete(index: Product.__elasticsearch__.index_name,
                    type: Product.__elasticsearch__.document_type,
                    id: record.id)
    else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
