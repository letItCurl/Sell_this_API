require 'rails_helper'

RSpec.describe "Classifieds", type: :request do
  describe 'GET /calssifieds' do
    before {
      FactoryGirl.create_list :classified, 3
      get "/classifieds"
    }

    it 'work' do
      expect(response).to have_http_status(200)
    end

    it 'return all the entries' do
      expect(parsed_body.count).to eq Classified.all.count
    end

  end

  describe 'GET /classifieds/:id' do
    let(:classified) {FactoryGirl.create :classified}
    before {get "/classifieds/#{classified.id}"}

    it 'works' do
      expect(response).to have_http_status(200)
    end
    it 'is correctly serialized' do 
      expect(parsed_body['id']).to eq classified.id
      expect(parsed_body['title']).to eq classified.title
      expect(parsed_body['price']).to eq classified.price
      expect(parsed_body['description']).to eq classified.description
    end
  end
end
