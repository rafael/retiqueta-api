class AccountBootstrap < ActiveJob::Base
  queue_as :default

  DEFAULT_USER_TO_FOLLOW = %w(johanna
                              gaby
                              norma
                              rafael
                              juanfa
                              retiqueta)

  def perform(user)
    users_to_follow = User.where(username: DEFAULT_USER_TO_FOLLOW)
    users_to_follow.each do |target_follow|
      #user.active_relationships.create!(followed_id: target_follow.uuid)
      Users::Follow.call(follower_id: user.uuid,
                         followed_id: target_follow.uuid)
    end
  end
end
