module Spree
  CheckoutController.class_eval do
    before_filter :confirm_sisow, only: [:update]

    def sisow_return
      handle_sisow_response
      @order.reload.next
      if @order.complete?
        flash.notice = Spree.t(:order_processed_successfully)
        redirect_to order_path(@order, number: @order.number)
      else
        redirect_to checkout_state_path(@order.state)
      end
    end

    def sisow_cancel
      handle_sisow_response
      redirect_to checkout_state_path(@order.state)
    end

    private

    def handle_sisow_response
      sisow = PaymentMethod::SisowBilling.new(@order)
      sisow.process_response(params)

      if sisow.cancelled?
        flash.alert = Spree.t(:payment_has_been_cancelled)
      end
    end

    def confirm_sisow
      return unless (params[:state] == "payment") && params[:order][:payments_attributes]

      payment_method = PaymentMethod.find(payment_method_id_param)

      opts = return_url_opts
      if payment_method.is_a?(PaymentMethod::SisowBilling::Ideal)
        opts[:issuer_id] = params[:issuer_id]
      end

      redirect_to payment_method.redirect_url(@order, opts)
    end

    def return_url_opts
      {
        return_url: sisow_return_order_checkout_url(@order),
        cancel_url: sisow_cancel_order_checkout_url(@order),
        notify_url: sisow_status_update_url(@order),
        callback_url: sisow_status_update_url(@order),
      }
    end

    def payment_method_id_param
      params[:order][:payments_attributes].first[:payment_method_id]
    end
  end
end
