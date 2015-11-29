class Comment < ActiveRecord::Base
  belongs_to :user, primary_key: :uuid
end
