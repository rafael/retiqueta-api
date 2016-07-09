require 'open-uri'
require 'rack/mime'

# Job that prefills user info based on facebook
# data
class PrefillUserDataFromFb < ActiveJob::Base
  queue_as :default

  def perform(user, fb_first_name, fb_last_name, fb_picture, fb_bio, fb_website)
    user.profile.first_name = fb_first_name unless fb_first_name.blank?
    user.profile.last_name = fb_last_name unless fb_last_name.blank?
    user.profile.bio = fb_bio unless fb_bio.blank?
    user.profile.website = fb_website unless fb_website.blank?
    user.profile.save!
    upload_profile_picture(user, fb_picture) if fb_picture
  end

  def upload_profile_picture(user, fb_picture)
    return unless fb_picture
    return unless fb_picture['data']
    return if fb_picture['data']['is_silhouette']
    fb_picture_url = fb_picture['data']['url']
    io = open(URI.parse(fb_picture_url))
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: io,
      filename: "#{SecureRandom.uuid}#{Rack::Mime::MIME_TYPES.invert[io.content_type]}"
    )
    uploaded_file.content_type = io.content_type
    user.profile.pic = uploaded_file
    user.profile.save!
  rescue => e
    Rollbar.error(e)
    Librato.increment 'user.facebook_connect.invalid_picture'
  end
end
