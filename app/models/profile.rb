class Profile < ActiveRecord::Base
  belongs_to :user

  has_attached_file :pic,
                    styles: {
                      small:  '150x150#',
                      large: '320X320#'
                    },
                    path: '/system/:hash.:extension',
                    default_url: 'https://s3-us-west-1.amazonaws.com/retiqueta-stage-img/guess_user_:style.png',
                    keep_old_files: true,
                    hash_secret: Rails.application.secrets.secret_key_base

  process_in_background :pic

  validates_attachment_content_type :pic, content_type: /\Aimage\/.*\Z/

  validates :bio, format: { with: /\A[^0-9]+\z/ }, allow_blank: true

  has_one :bank_account
end
