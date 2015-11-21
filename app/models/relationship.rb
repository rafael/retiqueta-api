class Relationship < ActiveRecord::Base
  belongs_to :follower,
             class_name: 'User',
             primary_key: :uuid
  belongs_to :followed,
             class_name: 'User',
             primary_key: :uuid
end
