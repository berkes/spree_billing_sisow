module Spree
  module Admin
    class SisowController < Spree::Admin::BaseController
      def edit
      end

      def update
        Spree::Config.set(update_params.to_hash)
        redirect_to edit_admin_sisow_path, :notice => Spree.t(:sisow_settings_updated)
      end

      private

      def update_params
        params.require(:preferences).permit(:sisow_merchant_id,
                                            :sisow_merchant_key,
                                            :sisow_test_mode,
                                            :sisow_debug_mode)
      end
    end
  end
end
