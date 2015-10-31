class MillisecondsMigration < ActiveRecord::Migration
  # https://gist.github.com/iamatypeofwalrus/d074d22a736d49459b15
  # Include non default date stamps here
  # Key   :table_name
  # value [:column_names]
  # NOTE: only MySQL 5.6.4 and above supports DATETIME's with more precision than a second.
  TABLES_AND_COLUMNS =  {
    :users => [],
    :products => [],
    :profiles => [],
    :product_pictures => [],
  }

  STANDARD_ACTIVE_RECORD_COLUMNS = [:created_at, :updated_at]

  TABLES_AND_COLUMNS.each {|k,v| v.concat(STANDARD_ACTIVE_RECORD_COLUMNS)}

  def up
    TABLES_AND_COLUMNS.each do |table, columns|
      columns.each do |column|
        # MySQL supports time precision down to microseconds -- DATETIME(6)
        change_column table, column, :datetime, limit: 3
      end
    end
  end

  def down
    TABLES_AND_COLUMNS.each do |table, columns|
      columns.each do |column|
        echange_column table, column, :datetime
      end
    end
  end
end
