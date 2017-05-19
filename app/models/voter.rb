# coding: utf-8
require 'csv'
class Voter < ActiveRecord::Base

  establish_connection "moviento_sexta_#{Rails.env}".to_sym

  def self.import(csv)
    CSV.foreach(csv) do |row|
      Voter.create!(cit: row[0],
                    ci: row[1],
                    name: row[2],
                    last_name: row[3],
                    mobile: row[4],
                    landline: row[5],
                    email: row[6],
                    mun: row[7],
                    parr: row[8],
                    voting_center_code: row[10])
    end
  end
end
