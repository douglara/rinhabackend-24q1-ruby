require 'rails_helper'

RSpec.describe "Transacoes", type: :request do
  describe "GET  /clientes/{client_id}/transacoes" do

    context 'when customer exists' do
      let(:request_body) { {
        "valor": 1000,
        "tipo": "c",
        "descricao": "descricao"
    }.to_json }

      it "returns http success" do
        post "/clientes/1/transacoes", params: request_body
        expect(response).to have_http_status(:success)
      end

      context "seed data about customer 1" do
        context 'credit' do
          let(:expect_result) {
            {
              "limite": 100000,
              "saldo": 1000
            }.to_json
          }

          it do
            post "/clientes/1/transacoes", params: request_body

            expect(response.body).to eq(expect_result)
          end
        end

        context 'debit' do
          context 'with available balance' do
            let(:request_body) { {
              "valor": 1000,
              "tipo": "d",
              "descricao": "descricao"
            }.to_json }

            let(:expect_result) {
              {
                "limite": 100000,
                "saldo": -1000
              }.to_json
            }

            it do
              post "/clientes/1/transacoes", params: request_body

              expect(response.body).to eq(expect_result)
            end

            it 'max debit possible' do
              post "/clientes/1/transacoes", params: {
                "valor": 100000,
                "tipo": "d",
                "descricao": "descricao"
              }.to_json

              expect(response.body).to eq( {
                "limite": 100000,
                "saldo": -100000
              }.to_json)
            end
          end

          context 'without available balance' do
            let(:request_body) { {
              "valor": 100001,
              "tipo": "d",
              "descricao": "descricao"
            }.to_json }
            it do
              post "/clientes/1/transacoes", params: request_body

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end
    end

    context 'when customer not exists' do
      it "returns http success" do
        post "/clientes/100/transacoes"
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'invalid requests' do
      it "invalid transaction kind" do
        post "/clientes/1/transacoes", params: {
          "valor": 1000,
          "tipo": "x",
          "descricao": "devolve"
        }.to_json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "without description" do
        post "/clientes/1/transacoes", params: {
          "valor": 1000,
          "tipo": "d"
        }.to_json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "decimal amount" do
        post "/clientes/1/transacoes", params: {
          "valor": 1.2,
          "tipo": "d",
          "descricao": "devolve"
        }.to_json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "blank description" do
        post "/clientes/1/transacoes", params: {
          "valor": 1000,
          "tipo": "d",
          "descricao": ""
        }.to_json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "bigger description" do
        post "/clientes/1/transacoes", params: {
          "valor": 1000,
          "tipo": "d",
          "descricao": "description more then 10 characters"
        }.to_json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
