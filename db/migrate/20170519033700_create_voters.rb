#ActiveRecord::Base.establish_connection("moviento_sexta_#{Rails.env}".to_sym)
class CreateVoters < ActiveRecord::Migration
#  def connection
#    ActiveRecord::Base.establish_connection("moviento_sexta_#{Rails.env}".to_sym)
#  end
  def change
#    config = ActiveRecord::Base.configurations["moviento_sexta_#{Rails.env}"]
#
#   # Database is null because it hasn't been created yet.
#    ActiveRecord::Base.establish_connection(config.merge('database' => nil))
#    ActiveRecord::Base.connection.create_database(config['database'], config)
#    ActiveRecord::Base.establish_connection("moviento_sexta_#{Rails.env}".to_sym)
#    ActiveRecord::Base.connection.reconnect!


    Voter.connection.create_table :voters do |t|
      t.string :cit
      t.string :ci
      t.string :name
      t.string :last_name
      t.string :mobile
      t.string :landline
      t.string :email
      t.string :mun
      t.string :parr
      t.string :voting_center
      t.string :voting_center_code
      t.timestamps null: false
    end
#    ActiveRecord::Base.establish_connection(Rails.env)
  end
end
