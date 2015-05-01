# Helpers to stub out parts of Spree
module SpreeStubs
  # Fakes a user with an order.
  # It allows us to not have to click through the entire checkout process
  # just to get a user with a session and an order.
  def stub_user_with_order(user, order)
    allow_any_instance_of(Spree::CheckoutController)
      .to receive(:current_order)
      .and_return(order)
    allow_any_instance_of(Spree::CheckoutController)
      .to receive(:try_spree_current_user)
      .and_return(user)
    allow_any_instance_of(Spree::OrdersController)
       .to receive(:try_spree_current_user)
      .and_return(user)
  end
end
