require 'rails_helper'

RSpec.describe "Table Tennis API", type: :request do

    describe '#ping' do
        context "When unauthenticated" do
            it 'returns unauthenticated pong' do
                get '/ping'
                expect(parsed_body['response']).to eq 'unauthorized pong'
            end     
        end

        context "When authenticated" do
            
            before { get '/ping', headers: authentication_header}

            it 'works' do
                expect(response).to have_http_status(200)
            end     

            it "returns authorized" do
                expect(parsed_body['response']).to eq 'authorized pong'
            end

        end


    end
end
