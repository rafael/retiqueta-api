class AccountBootstrap < ActiveJob::Base
  queue_as :default

  DEFAULT_USER_TO_FOLLOW = %w(edmaryfuentes
                              unatalluisa
                              SRboutiqueshop
                              marianamolina
                              valentinaos26210
                              retiqueta
                              pinaycoco
                              carolavidalt2914
                              mariagabrielita07
                              GabyC
                           )

  def perform(user)
    users_to_follow = User.where(username: DEFAULT_USER_TO_FOLLOW)
    users_to_follow.each do |target_follow|
      # user.active_relationships.create!(followed_id: target_follow.uuid)
      Users::Follow.call(follower_id: user.uuid,
                         followed_id: target_follow.uuid)
    end
  end
end
