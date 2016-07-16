class Profile < ActiveRecord::Base
  belongs_to :user

  has_attached_file :pic,
                    styles: {
                      small:  '100x100#',
                      large: '350X350#'
                    },
                    url: ':s3_domain_url',
                    path: '/system/:hash.:extension',
                    default_url: 'https://s3-us-west-1.amazonaws.com/retiqueta-stage-img/guess_user_:style.png',
                    keep_old_files: true,
                    hash_secret: Rails.application.secrets.secret_key_base

  process_in_background :pic

  validates_attachment_content_type :pic, content_type: /\Aimage\/.*\Z/

  has_one :bank_account
end
