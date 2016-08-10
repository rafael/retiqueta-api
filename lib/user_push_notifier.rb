class UserPushNotifier

  attr_accessor :message, :users, :perform_at

  def initialize(params = {})
    @message = params.fetch(:message)
    @users = params.fetch(:users)
    @perform_at = params.fetch(:perform_at)
  end

  def send
    SendPushNotification
      .set(wait_until: perform_at)
      .perform_later(users.to_a,
                     'Retiqueta',
                     message,
                     {})
  end
end
