class Profile < ActiveRecord::Base
  belongs_to :user

  has_attached_file :pic,
                    styles: {
                      thumb: '100x100>',
                      square: '200x200#',
                      medium: '300x300>'
                    },
                    url: "/system/:hash.:extension",
                    hash_secret: Rails.application.secrets.secret_key_base

  validates_attachment_content_type :pic, :content_type => /\Aimage\/.*\Z/

end
