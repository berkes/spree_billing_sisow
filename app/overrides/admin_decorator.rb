Deface::Override.new(
  virtual_path: "spree/admin/shared/sub_menu/_configuration",
  name: "add_sisow_settings",
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  partial: "spree/admin/shared/configurations_menu_sisow")
