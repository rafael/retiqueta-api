class User < ActiveRecord::Base

  validates :username, format: { with: /\A[a-zA-Z0-9]+\z/ }

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

  acts_as_voter

  ##################
  ## associations ##
  ##################

  has_one :profile, autosave: true
  has_one :facebook_account, primary_key: :uuid
  has_many :products, primary_key: :uuid
  has_many :payouts, primary_key: :uuid
  has_many :sales, primary_key: :uuid
  has_many :push_tokens, primary_key: :uuid

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
           source: :follower,
           primary_key: :uuid

  has_many :following,
           through: :active_relationships,
           source: :followed,
           primary_key: :uuid

  delegate :pic, :first_name, :last_name, :bio,
           :website, :country, :bank_account, :store_fee, to: :profile

  def following?(user)
    active_relationships.where(followed_id: user.uuid).count > 0
  end

  def followers_count
    passive_relationships.count
  end

  def following_count
    active_relationships.count
  end

  def available_balance
    sales_amount = sales.map(&:amount).reduce(0, &:+)
    payout_amount = payouts.map(&:amount).reduce(0, &:+)
    sales_amount - payout_amount
  end

  def self.find_by_facebook_id(uuid)
    FacebookAccount.find_by_uuid(uuid.to_s).try(:user)
  end

  def name
    return username if first_name.blank?
    first_name.capitalize
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
