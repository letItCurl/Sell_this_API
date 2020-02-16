require 'rails_helper'
require 'pp'

RSpec.describe "Classifieds", type: :request do
  let(:classified) {FactoryGirl.create :classified, user_id: current_user.id}
  describe 'GET /v1/calssifieds' do
    context 'everything is going well' do
      let(:page) {3}
      let(:per_page) {5}
      before {
        FactoryGirl.create_list :classified, 18
        get "/v1/classifieds", params: {page: page, per_page: per_page}
      }
      it 'work' do
        expect(response).to have_http_status(206)
      end
      it 'return paginated result' do
        expect(parsed_body.map {|c| c['id']}).to eq Classified.all.limit(per_page).offset((page-1)*per_page).pluck(:id)
      end
    end
    it 'returns a bad request when params are missing' do
      get '/v1/classifieds/'
      expect(response).to have_http_status :bad_request
      expect(parsed_body.keys).to include 'error'
      expect(parsed_body['error']).to eq 'missing parameters'
    end
  end

  describe 'GET /v1/classifieds/:id' do
    context 'when everything goes well' do
      before {get "/v1/classifieds/#{classified.id}"}
      it 'works' do
        expect(response).to have_http_status(200)
      end
      it 'is correctly serialized' do 
        expect(parsed_body).to match({
          id: classified.id,
          title: classified.title,
          price: classified.price,
          description: classified.description,
          user:{
            id: classified.user.id,
            fullname: classified.user.fullname
          }.stringify_keys
        }.stringify_keys)
      end
    end
    it 'returns not found when the resource can not be found' do
      get "/v1/classifieds/lala" 
      expect(response).to have_http_status :not_found
    end
  end

  describe 'POST /v1/classifieds' do
    context "when unauthenticated" do
      it 'returns unauthorized' do
        post '/v1/classifieds'
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'when authenticated' do
      let(:params) {
        { classified: {title: 'title', price: '62', description: 'description'}}
      }
      it 'works' do
        post '/v1/classifieds', params: params, headers: authentication_header
        expect(response).to have_http_status :created
      end
      it 'creates a new classified' do
        expect{
          post '/v1/classifieds', params: params, headers: authentication_header
        }.to change {
          current_user.classifieds.count
        }.by 1
      end
      it 'has correct fields values for the created classified' do
        post '/v1/classifieds', params: params, headers: authentication_header
        created_classified = current_user.classifieds.last
        expect(created_classified.title).to eq 'title'
        expect(created_classified.price).to eq 62
        expect(created_classified.description).to eq 'description'
      end
      it 'returns a bad request when a parameter is missing' do
        params[:classified].delete(:price)
        post '/v1/classifieds', params: params, headers: authentication_header
        expect(response).to have_http_status :bad_request
      end

      it 'returns a bad request when price not a number' do
        params[:classified][:price] = "blabla"
        post '/v1/classifieds', params: params, headers: authentication_header
        #puts parsed_body
        expect(response).to have_http_status :bad_request
      end
    end
  end

  describe 'PATCH /v1/classifieds/:id' do
    
    let(:params) {
      { classified: {title: 'title', price: '62'}}
    }
    context 'when unauthenticated' do
      it 'returns unauthorized' do
        patch "/v1/classifieds/#{classified.id}"
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when authenticated' do
      context 'when everything goes well' do
        before {patch "/v1/classifieds/#{classified.id}", params: params, headers: authentication_header}
        it { expect(response).to have_http_status(200) }
        it 'modifies the given fields of the resource' do
          modified_classified = Classified.find(classified.id)
          expect(modified_classified.title).to eq 'title'
          expect(modified_classified.price).to eq 62
        end
      end

      it 'returns a bad request when a parameter is malformed' do
        params[:classified][:price] = 'looops'
        patch "/v1/classifieds/#{classified.id}", params: params, headers: authentication_header
        expect(response).to have_http_status :bad_request
      end
      it 'returns a not found resource can not be found' do
        patch '/v1/classifieds/tinpuzar', params: params, headers: authentication_header
        expect(response).to have_http_status :not_found
      end
      it 'returns a forbidden when the requester is not the owner of the ressource' do
        another_classified = FactoryGirl.create :classified
        patch "/v1/classifieds/#{another_classified.id}", params: params, headers: authentication_header
        expect(response).to have_http_status :forbidden
      end
    end

  end

  describe 'DELETE /v1/classifieds/:id' do
    context 'when unauthenticated' do
      it 'return unautorized' do
        delete "/v1/classifieds/#{classified.id}"
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'when authenticated' do 
      context 'when everything goes well' do
        before {delete "/v1/classifieds/#{classified.id}", headers: authentication_header}
        it { expect(response).to have_http_status :no_content}
        it 'deletes the given classifed' do
          expect(Classified.find_by(id: classified.id)).to eq nil
        end
        it 'returns a forbidden when the requester is not the owner of the ressource' do
          another_classified = FactoryGirl.create :classified
          delete "/v1/classifieds/#{another_classified.id}", headers: authentication_header
          expect(response).to have_http_status :forbidden
        end

      end
      it 'returns a not found resource can not be found' do
        delete '/v1/classifieds/tinpuzar', headers: authentication_header
        expect(response).to have_http_status :not_found
      end
    end

  end

end
