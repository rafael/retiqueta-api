class Product < ActiveRecord::Base
  ##################
  ## associations ##
  ##################
  belongs_to :user, primary_key: :uuid
  has_many :product_pictures, primary_key: :uuid

  ###############
  ## Callbacks ##
  ###############

  before_create :generate_uuid

  after_commit  on: [:create, :update] { ProductsIndexer.perform_later(self, 'index') }
  after_destroy on: [:destroy] { ProductsIndexer.perform_later(self, 'delete') }

  ################
  ## Extensions ##
  ################

  include Elasticsearch::Model

  #############################
  ## Elastic Search Settings ##
  #############################

  index_name "products-#{Rails.env}"

  def self.clean_elastic_search_index
    self.__elasticsearch__.client.indices.delete(index: self.index_name)
  end

  def self.elastic_search_settings
    {
      index: {
        number_of_shards: 5,
        number_of_replicas: 0,
        analysis: {
          filter: {
            spanish_stop: {
              type: "stop",
              stopwords:"_spanish_"
            },
            spanish_stemmer: {
              type: "stemmer",
              language:   "light_spanish"
            }
          },
          analyzer: {
            spanish: {
              tokenizer:  "standard",
              filter: [
                "lowercase",
                "spanish_stop",
                "spanish_stemmer",
                "asciifolding"
              ]
            }
          }
        }
      }
    }
  end

  settings(elastic_search_settings) do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'spanish'
      indexes :description, analyzer: 'spanish'
      indexes :category, analyzer: 'spanish'
      indexes :status, type: "string", index: "not_analyzed"
    end
  end

  CATEGORIES = ["shoes", "garment"]

  def self.search(options = {})
    self.__elasticsearch__.search(
      {
        query: {
          filtered: {
            query: {
              multi_match: {
                query: options[:query],
                fields: [ "title^3", "category", "description", "status" ],
              }
            },
            filter: {
              term: { status: "published" }
            }
          }
        }
      }
    )
  end

  def as_indexed_json(options={})
    self.as_json(options.merge(include: :product_pictures, root: false))
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
