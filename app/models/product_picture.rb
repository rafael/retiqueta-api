class ProductPicture < ActiveRecord::Base
  belongs_to :user, primary_key: :uuid
  belongs_to :product, primary_key: :uuid

  has_attached_file :pic,
                    styles: {
                      small:  '320x320#',
                      large: '720x720#',
                      medium: '450x450#',
                    },
                    url: ':s3_domain_url',
                    path: "/product_pictures/:hash.:extension",
                    hash_secret: Rails.application.secrets.secret_key_base

  process_in_background :pic

  validates_attachment_content_type :pic, :content_type => /\Aimage\/.*\Z/

end
