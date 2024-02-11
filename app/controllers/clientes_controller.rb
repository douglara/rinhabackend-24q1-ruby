class ClientesController < ApplicationController

  def extrato
    load_customer
    validate_customer and return
    render json: build_extrato, status: :ok
  end

  def build_extrato
    data_extrato = Time.current.iso8601(6)
    last_transactions = Transaction.where.not(kind: 0).where(customer_id: params[:id]).order(created_at: :desc).limit(10).pluck(:amount,:kind,:description,:created_at)
    last_transactions = last_transactions.map do | transaction |
      {
        valor: transaction[0],
        tipo: transaction[1],
        descricao: transaction[2],
        realizada_em: transaction[3].iso8601(6),
      }
    end

    result = {
      "saldo": {
        "total": @customer.customer_balance_cents,
        "data_extrato": data_extrato,
        "limite": @customer.customer_limit_cents
      },
      "ultimas_transacoes": last_transactions
    }
  end

  def transacoes
    load_customer
    validate_customer and return
    build_new_customer_balance_cents
    validate_transaction_amount and return
    render json: build_transaction_result, status: :ok
    rescue
      render status: :unprocessable_entity
  end

  def invalid_transaction?(new_customer_balance_cents)
    if params[:tipo] == 'd'
      if new_customer_balance_cents < (-@customer.customer_limit_cents)
        return true
      end
    end

    false
  end

  def build_transaction_result
    @new_customer = Transaction.create(
      customer_id: params[:id],
      customer_limit_cents: @customer.customer_limit_cents,
      customer_balance_cents: @new_customer_balance_cents,
      amount: params[:valor],
      kind: @kind,
      description: params[:descricao],
    )

    {
      "limite": @new_customer.customer_limit_cents,
      "saldo": @new_customer.customer_balance_cents
    }
  end

  def build_new_customer_balance_cents
    if params[:tipo] == "c"
      @new_customer_balance_cents = @customer.customer_balance_cents + params[:valor]
      @kind = 1
    else
      @new_customer_balance_cents = @customer.customer_balance_cents - params[:valor]
      @kind = 2
    end
  end

  def validate_transaction_amount
    if invalid_transaction?(@new_customer_balance_cents)
      render status: :unprocessable_entity and return true
    end
  end

  def load_customer
    @customer = Transaction.where(customer_id: params[:id]).order(id: :desc).limit(1).first
  end

  def validate_customer
    if @customer.blank?
      render status: :not_found and return true
    end
  end
end
