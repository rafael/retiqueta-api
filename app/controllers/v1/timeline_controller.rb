require 'ostruct'

class V1::TimelineController < ApplicationController
  def index
    page = params.fetch(:page) { {} }
    per_page = page[:size] || 25
    page_num = page[:number] || 1
    outcome = Timeline::Card.all.order(created_at: :desc).page(page_num).per(per_page)
    render json: outcome,
           status: 200
  end
end
