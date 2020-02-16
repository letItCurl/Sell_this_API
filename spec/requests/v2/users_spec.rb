require 'rails_helper'
require 'pp'

RSpec.describe "Users API", type: :request do
    describe 'GET /v2/users/:id' do
        before { get "/v2/users/#{current_user.id}", headers: authentication_header}
        it { expect(response).to have_http_status :success}
        it 'is correctly serialized' do
            expect(parsed_body).to match({
                id: current_user.id,
                firstname: current_user.firstname,
                lastname: current_user.lastname,
                username: current_user.username
            }.stringify_keys)
        end
    end

end
