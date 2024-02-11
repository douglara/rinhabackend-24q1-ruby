require 'rails_helper'

RSpec.describe "Extrato", type: :request do
  describe "GET  /clientes/{client_id}/extrato" do

    context 'when customer exists' do
      it "returns http success" do
        get "/clientes/1/extrato"
        expect(response).to have_http_status(:success)
      end

      context "seed data about customer 1" do
        let(:expect_result) {
          {
            "saldo": {
              "total": 0,
              "data_extrato": "2024-01-17T02:34:41.000000Z",
              "limite": 100000
            },
            "ultimas_transacoes": []
          }.to_json
        }

        it do
          travel_to Time.parse('2024-01-17T02:34:41.217753Z')
          get "/clientes/1/extrato"
          expect(response.body).to eq(expect_result)
        end
      end

      context 'with transactions' do
        it do
          travel_to Time.parse('2024-01-17T02:34:41.217753Z')
          t1 = Transaction.find_or_create_by!(
            customer_id: 1,
            customer_limit_cents: 100000,
            customer_balance_cents: -1000,
            amount: 1000,
            description: "Debito",
            kind: 1,
          )

          t2 = Transaction.find_or_create_by!(
            customer_id: 1,
            customer_limit_cents: 100000,
            customer_balance_cents: -2000,
            amount: 1000,
            description: "Debito",
            kind: 1
          )
          result = {"saldo": {"total": t2.customer_balance_cents,"data_extrato": "2024-01-17T02:34:41.000000Z","limite": 100000},"ultimas_transacoes": [{"valor": 1000,"tipo": "c","descricao": "Debito","realizada_em": "2024-01-17T02:34:41.000000Z"},{"valor": 1000,"tipo": "c","descricao": "Debito","realizada_em": "2024-01-17T02:34:41.000000Z"}]}.to_json

          get "/clientes/1/extrato"
          expect(response.body).to eq(result)
        end
      end
    end

    context 'when client not exists' do
      it "returns http success" do
        get "/clientes/100/extrato"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
