Elasticsearch::Model.client = Elasticsearch::Client.new(host: Rails.configuration.x.elastictsearch.host,
                                                        log: Rails.configuration.x.elastictsearch.log)
