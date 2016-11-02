require 'ar_uuid_generator'

class Product < ActiveRecord::Base
  PUBLISHED_STATUS = 'published'
  SOLD_STATUS = 'sold'

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid
  has_many :product_pictures, -> { order(position: :asc) }, primary_key: :uuid
  has_one :conversation, as: :commentable, dependent: :delete
  delegate :comments, to: :conversation

  ###############
  ## Callbacks ##
  ###############

  before_create :generate_converstation

  after_commit on: [:create, :update] { ProductsIndexer.perform_later(self.id, 'index') }
  after_destroy on: [:destroy] { ProductsIndexer.perform_later(self.id, 'delete') }

  ################
  ## Extensions ##
  ################

  include Elasticsearch::Model
  include ArUuidGenerator

  acts_as_votable

  #############################
  ## Elastic Search Settings ##
  #############################

  index_name "products-#{Rails.env}"

  def self.clean_elastic_search_index
    __elasticsearch__.client.indices.delete(index: index_name)
  end

  def self.reindex_elastict_search
    clean_elastic_search_index
    __elasticsearch__.create_index!
    import
  end

  def self.elastic_search_settings
    {
      index: {
        number_of_shards: 5,
        number_of_replicas: 0,
        analysis: {
          filter: {
            spanish_stop: {
              type: 'stop',
              stopwords: '_spanish_'
            },
            spanish_stemmer: {
              type: 'stemmer',
              language:   'light_spanish'
            }
          },
          analyzer: {
            spanish: {
              tokenizer:  'standard',
              filter: %w(
                lowercase
                spanish_stop
                spanish_stemmer
                asciifolding)
            }
          }
        }
      }
    }
  end

  settings(elastic_search_settings) do
    mappings dynamic: 'false' do
      indexes :description, analyzer: 'spanish'
      indexes :username, analyzer: 'spanish'
      indexes :title, analyzer: 'spanish'
      indexes :category, analyzer: 'spanish'
      indexes :status, type: 'string', index: 'not_analyzed'
      indexes :likes, type: 'long', index: 'not_analyzed'
      indexes :created_at, type: 'date', index: 'not_analyzed'
      indexes :origin_time, type: 'date', index: 'not_analyzed'
    end
  end

  def self.search(options = {})
    return self.match_all if options[:query].blank?
    __elasticsearch__.search(
      query: {
        function_score: {
          query: {
            filtered: {
              query: {
                multi_match: {
                  query: options[:query],
                  fields: ['category', 'description^3', 'status', 'username^4']
                }
              },
              filter: {
                term: { status: 'published' }
              }
            }
          },
          functions: [
            {
              gauss: {
                origin_time: {
                  origin: 'now',
                  scale: '24h',
                  decay: '.07'
                }
              }
            }
          ]
        }
      }
    ) # .page(options.fetch(:page, 1)).per(options.fetch(:per_page, 25))
  end

  def self.match_all
    __elasticsearch__.search(
      query: {
        function_score: {
          query: {
            filtered: {
              query: {
                 match_all: {}
              },
              filter: {
                term: { status: 'published' }
              }
            }
          },
          functions: [
            {
              gauss: {
                origin_time: {
                  origin: 'now',
                  scale: '24h',
                  decay: '.07'
                }
              }
            }
          ]
        }
      }
    ) # .page(options.fetch(:page, 1)).per(options.fetch(:per_page, 25))
  end

  def origin
    f = 1
    factor = 0.0
    self.votes_for.each do |v|
      factor = factor + f
      f = f * 0.995
    end
    if ( factor > 0 )
      origin_time = self.created_at + factor.day
      origin_time > Time.now ? Time.now : origin_time
    else
      self.created_at
    end
  end

  def as_indexed_json(options = {})
    as_json(options.merge(include: :product_pictures, root: false))
      .merge('username' => user.username, 'likes' => self.votes_for.size, 'created_at' => self.created_at, 'origin_time' => origin)
  end

  def generate_converstation
    conversation || build_conversation
  end
end
