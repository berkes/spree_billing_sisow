module Spree
  class SisowStatusController < ApplicationController
    def update
      begin
        order = Order.find_by_number!(params[:order_id])
        sisow = PaymentMethod::SisowBilling.new(order)
        sisow.process_response(params)

        order.next unless order.completed?
        head :ok
      rescue ActiveRecord::RecordNotFound
        logger.error "ERROR: Sisow reply failed, order (#{params[:order_id]}) not found"
        head :internal_server_error
      end
    end

  end
end
