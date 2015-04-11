Spree::AppConfiguration.class_eval do
  # Sisow Preferences
  preference :sisow_merchant_id, :string, :default => '2537407799'
  preference :sisow_merchant_key, :string, :default => '0f9b49d384b4836c543f76d23a923e2cd2cfaec6'
  preference :sisow_test_mode, :boolean, :default => true
  preference :sisow_debug_mode, :boolean, :default => false
end