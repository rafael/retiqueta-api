# coding: utf-8
require 'rails_helper'

RSpec.describe Product, type: :model do
  include ActiveJob::TestHelper

    describe "#save" do
    it "enqueues product to be indexed by elastic search" do
      product = build(:product)
      expect do
        product.save
        product.run_callbacks(:commit)
      end.to change(enqueued_jobs, :size).by(1)
    end
  end


  describe ".search", :vcr do
    before(:all) do
      VCR.use_cassette("product_search/before_all") do
        create(:product, title: "Vendo #nike", description: "como nuevos", category: "zapatos",  status: "published")
        described_class.import(force: true)
      end
      #sleep 1 # Let elastic search finish the indexing, only run this when saving the cassettes.
    end

    after(:all) do
      VCR.use_cassette("product_search/after_all") do
        described_class.clean_elastic_search_index
      end
    end

    it "only finds published products" do
      create(:product, title: "Vendo franela addidas")
      search_result = Product.search(query: "addidas")
      expect(search_result.count).to eq(0)
    end

    it "does asciifolding" do
      search_result = Product.search(query: "cómo nuevos")
      expect(search_result.count).to eq(1)
    end

    it "does word stemming" do
      search_result = Product.search(query: "zapato")
      expect(search_result.count).to eq(1)
    end

    it "finds a product by in case insesitive way" do
      search_result = Product.search(query: "NIKE")
      expect(search_result.count).to eq(1)
    end

    it "finds a product by attributes hashtag" do
      search_result = Product.search(query: "nike")
      expect(search_result.count).to eq(1)
    end

    it "finds a product by attributes in the title" do
      search_result = Product.search(query: "Vendo")
      expect(search_result.count).to eq(1)
    end

    it "finds a product by attributes in the description" do
      search_result = Product.search(query: "nuevos")
      expect(search_result.count).to eq(1)
    end

    it "finds a product by attributes in the category" do
      search_result = Product.search(query: "zapatos")
      expect(search_result.count).to eq(1)
    end
  end
end
