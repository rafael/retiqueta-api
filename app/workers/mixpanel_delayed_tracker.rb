class MixpanelDelayedTracker < ActiveJob::Base
  queue_as :default

  def perform(user_id, event, params)
    tracker.track(user_id, event, params)
  end

  def tracker
    @tracker ||= Mixpanel::Tracker.new(
      Rails.application.secrets.mixpanel_token
    )
  end
end
