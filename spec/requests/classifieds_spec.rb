require 'rails_helper'

RSpec.describe "Classifieds", type: :request do
  let(:classified) {FactoryGirl.create :classified, user_id: current_user.id}
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

  describe 'POST /classifieds' do
    context "when unauthenticated" do
      it 'returns unauthorized' do
        post '/classifieds'
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'when authenticated' do
      let(:params) {
        { classified: {title: 'title', price: '62', description: 'description'}}
      }
      it 'works' do
        post '/classifieds', params: params, headers: authentication_header
        expect(response).to have_http_status :created
      end
      it 'creates a new classified' do
        expect{
          post '/classifieds', params: params, headers: authentication_header
        }.to change {
          current_user.classifieds.count
        }.by 1
      end
      it 'has correct fields values for the created classified' do
        post '/classifieds', params: params, headers: authentication_header
        created_classified = current_user.classifieds.last
        expect(created_classified.title).to eq 'title'
        expect(created_classified.price).to eq 62
        expect(created_classified.description).to eq 'description'
      end
      it 'returns a bad request when a parameter is missing' do
        params[:classified].delete(:price)
        post '/classifieds', params: params, headers: authentication_header
        expect(response).to have_http_status :bad_request
      end

      it 'returns a bad request when price not a number' do
        params[:classified][:price] = "blabla"
        post '/classifieds', params: params, headers: authentication_header
        #puts parsed_body
        expect(response).to have_http_status :bad_request
      end
    end
  end

  describe 'PATCH /classifieds/:id' do
    
    let(:params) {
      { classified: {title: 'title', price: '62'}}
    }
    context 'when unauthenticated' do
      it 'returns unauthorized' do
        patch "/classifieds/#{classified.id}"
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when authenticated' do
      context 'when everything goes well' do
        before {patch "/classifieds/#{classified.id}", params: params, headers: authentication_header}
        it { expect(response).to have_http_status(200) }
        it 'modifies the given fields of the resource' do
          modified_classified = Classified.find(classified.id)
          expect(modified_classified.title).to eq 'title'
          expect(modified_classified.price).to eq 62
        end
      end

      it 'returns a bad request when a parameter is malformed' do
        params[:classified][:price] = 'looops'
        patch "/classifieds/#{classified.id}", params: params, headers: authentication_header
        expect(response).to have_http_status :bad_request
      end
      it 'returns a not found resource can not be found' do
        patch '/classifieds/tinpuzar', params: params, headers: authentication_header
        expect(response).to have_http_status :not_found
      end
      it 'returns a forbidden when the requester is not the owner of the ressource' do
        another_classified = FactoryGirl.create :classified
        patch "/classifieds/#{another_classified.id}", params: params, headers: authentication_header
        expect(response).to have_http_status :forbidden
      end
    end

  end

  describe 'DELETE /classifieds/:id' do
    context 'when unauthenticated' do
      it 'return unautorized' do
        delete "/classifieds/#{classified.id}"
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'when authenticated' do 
      context 'when everything goes well' do
        before {delete "/classifieds/#{classified.id}", headers: authentication_header}
        it { expect(response).to have_http_status :no_content}
        it 'deletes the given classifed' do
          expect(Classified.find_by(id: classified.id)).to eq nil
        end
        it 'returns a forbidden when the requester is not the owner of the ressource' do
          another_classified = FactoryGirl.create :classified
          delete "/classifieds/#{another_classified.id}", headers: authentication_header
          expect(response).to have_http_status :forbidden
        end

      end
      it 'returns a not found resource can not be found' do
        delete '/classifieds/tinpuzar', headers: authentication_header
        expect(response).to have_http_status :not_found
      end
    end

  end

end
