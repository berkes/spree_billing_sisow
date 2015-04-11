module Spree
  module Admin
    class SisowController < Spree::Admin::BaseController
      def edit
      end

      def update
        Spree::Config.set(params[:preferences])

        redirect_to edit_admin_sisow_path, :notice => Spree.t(:sisow_settings_updated)
      end
    end
  end
end