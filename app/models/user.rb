class User < ActiveRecord::Base

  ###############
  ## Callbacks ##
  ###############

  before_create :generate_uuid
  before_create :initialize_profile

  ################
  ## Extensions ##
  ################

  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  ##################
  ## associations ##
  ##################

  has_one :profile, autosave: true
  has_many :products, primary_key: :uuid

  has_many :active_relationships,
           class_name: 'Relationship',
           foreign_key: 'follower_id',
           primary_key: :uuid,
           dependent: :destroy

  has_many :passive_relationships,
           class_name: 'Relationship',
           foreign_key: 'followed_id',
           primary_key: :uuid,
           dependent: :destroy

  has_many :followers,
           through: :passive_relationships,
           source: :followed,
           primary_key: :uuid

  has_many :following,
           through: :active_relationships,
           source: :follower,
           primary_key: :uuid

  delegate :pic, :first_name, :last_name, :bio, :website, :country, to: :profile

  def following?(user)
    active_relationships.where(followed_id: user.uuid).count > 0
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def initialize_profile
    # only build profile if it hasn't been set.
    profile || build_profile
  end
end
