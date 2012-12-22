App::Application.routes.draw do

  match "attachments/:attachment_type/:id", :to => 'attachments#get_attachment', :as => 'get_attachment'
  resources :attachments
  resources :comments

  devise_for :users

  match "home", :to => 'home#index', :as => :user_home

  match 'admin/project_process_units', :to => 'admin#project_process_units'
  match 'admin/client_projects', :to => 'admin#client_projects'
  match "admin", :to => 'admin#index', :as => :admin_home
  match "admin/sizing_data", :to => 'admin#sizing_data', :as => :default_data

  namespace :admin do

    resources :procures do
      collection do
        post "procure_rfq_sections"
        get "procure_rfq_sections_destroy"
        post "procure_additional_po_costs"
        get "procure_additional_po_costs_destroy"
      end
    end

    resources :pipings do

    end

    resources :mechanical_specifications do
      collection do
        post "itemtypes"
        get "itemtypes_destroy"
        post "vendor_requirement"
        get "vendor_requirement_destroy"
        post "datasheet"
        get "datasheet_destroy"
        get "datasheet_item_type"
      end
    end

    resources :relief_rate_calculation_views do
      collection do
        get 'view_generic'
        post 'save_generic'
      end
    end

    resources :scenario_summary_view_details do
      collection do
        get  'view_hydraulic_expansions'
        post 'save_hydraulic_expansions'
      end
    end

    resources :sizing_status_activities do
      collection do
        post 'change_status'
      end
    end

    match "summary_reports/:sizing", :to => 'summary_reports#sizing_summary_pdf', :as => :sizing_summary_pdf

    resources :company_users
    resources :groups
    resources :titles
    resources :units
    resources :roles

    resources :clients do
      member do
        get 'projects'
      end
    end

    resource :dashboard do
      collection do
        get "clients"
        get "projects"
        get "process_units"
        get "setdefault"
      end
    end

    resources :projects do
      member do
        get "edit/:step", :to => "projects#edit", :as => :edit_steps
        post "team_assignment"
        post "vendor_assignment"
        get "assign"
        get "assign_vendors"
        get "process_units"
        get "convert_and_round"
      end
      collection do
        get "project_case_details"
        get "project_details"
        post "update_case_details"
        get "vendor_setups"
        get "quotation"
        get "edit_vendor_schedule_setup"
        get "edit_purchase_vendor_schedule_setup"
        get "edit_as_built_vendor_schedule_setup"
        get "edit_with_shipment_vendor_schedule_setup"
        post "update_vendor_schedule_setup"
        post "update_purchase_vendor_schedule_setup"
        post "update_as_built_vendor_schedule_setup"
        post "update_with_shipment_vendor_schedule_setup"
        get "edit_request_for_quotation_setup"
        post "update_request_for_quotation_setup"
      end
    end

    resources :measure_units

    resources :measurements do
      collection do
        get 'get_measurement_sub_types'
      end
    end

    resources :measurement_sub_types
    resources :unit_of_measurements
    match '/heat_and_material_balances/get_sheet/:id/:name' => 'heat_and_material_balances#get_sheet', :as => 'get_hnm_balance_sheet'
    resources :heat_and_material_balances do
      member do
        post "delete_case"
      end
      collection do
        get "get_stream_nos"
      end
    end

    resources :pipe_roughness

    resources :sizing_criteria_categories
    resources :sizing_criteria_category_types
    resources :sizing_criterias do
      collection do
        get 'show_sizing_criterias'
        post 'add_sizing_criterias_to_project'
      end
    end

    resources :line_sizings do
      collection do
        get 'get_stream_values'
        get 'get_sizing_criteria_types'
        get 'get_sizing_criterias'
        get 'get_sizing_criteria_values'
        get 'line_sizing_summary'
        get 'sizing_criteria_calculation'
        get 'get_flow_regime'
        get 'design_condition_design'
        get 'straight_pipe_thickness_design'
        get 'target_two_phase_regime_estimate'
        get 'calculate_outer_diameter'
        post 'segment_sizing_criteria_calculation'
      end
      member do
        get 'clone'
      end
    end

    resources :vessel_sizings do
      collection do
        get 'get_feed_stream_nos'
        get 'get_top_outlet_stream_nos'
        get 'get_bottom_outlet_stream_nos'
        get 'get_vessel_sizing_hs_water_stream_nos'
        get 'vessel_sizing_summary'
        get 'filter_transfer_data'
        get 'reactor_transfer_data'
        get 'design_conditions_calculate'
        get 'mechanical_design_calculate'
        get 'get_nozzle_od'
        get 'feed_nozzle_calculation'
        get 'top_outlet_nozzle_calculation'
        get 'bottom_outlet_nozzle_calculation'
        get 'decanter_calculation'
        get 'horizontal_separator_calculation'
        get 'settler_calculation'
        get 'vertical_separator_calculation'
      end
      member do
        get 'clone'
      end

    end

    resources :pump_sizings do
      collection do
        get 'get_stream_values'
        get 'get_discharge_stream_nos'
        get 'clone_circuit_piping'
        get 'pump_sizing_summary'
        get 'suction_side_hydraulics'
        get 'discharge_side_hydraulics'
        get 'design_pump_centrifugal'
        get 'design_pump_reciprocation'
        get 'pump_suction_design'
        get 'equalize'
        get 'new_stream_property_changer'
        get 'get_change_properties_stream_values'
        get 'system_loss_calculate'
      end
      member do
        get 'clone'
      end
    end

    resources :compressor_sizings do
      collection do
        get 'get_stream_values'
        get 'get_discharge_stream_nos'
        get 'clone_circuit_piping'
        get 'compressor_sizing_summary'
        post 'add_compressor_sizing_mode'
        post 'edit_compressor_sizing_mode'
        post 'delete_compressor_sizing_mode'
        get 'suction_pipings'
        get 'discharges'
        get 'discharge_circuit_pipings'
        get 'discharge_circuit_piping_div'
        get 'suction_calculate'
        get 'discharge_calculate'
        get "centrifugal_design_calculate"
        get "reciprocation_design_calculate"
        get "rd_interstage_piping_calculate"
        get "cd_interstage_piping_calculate"
      end
      member do
        get 'clone'
      end
    end

    resources :driver_sizings do

    end

    resources :electric_motors do
      collection do
        get 'electric_motor_summary'
        get 'get_equiment_tag_by_equiment_type'
        get 'get_rotating_equipment_details'
      end
      member do
        get 'clone'
      end
    end

    resources :steam_turbines do
      collection do
        get 'get_stream_values'
        get 'steam_turbine_summary'
        get 'get_equiment_tag_by_equiment_type'
        get 'get_rotating_equipment_details'
        get 'steam_turbine_design_calculate'
        get 'estimate_efficiency_calculation'
      end
      member do
        get 'clone'
      end
    end

    resources :hydraulic_turbines do
      collection do
        get 'get_stream_values'
        get 'get_discharge_stream_nos'
        get 'hydraulic_turbine_summary'
        get 'suction_calculation'
        get 'get_equiment_tag_by_equiment_type'
        get 'get_rotating_equipment_details'
        get 'hprt_suctionside_hydraulics'
        get 'hprt_dischargeside_hydraulics'
        get 'hydraulic_turbine_design'
      end
      member do
        get 'clone'
      end
    end

    resources :turbo_expanders do
      collection do
        get 'get_stream_values'
        get 'get_expander_design_stream_values'
        get 'turbo_expanders_summary'
        get 'expander_design_calculation'
        get 'get_equiment_tag_by_equiment_type'
        get 'get_rotating_equipment_details'
      end
      member do
        get 'clone'
      end
    end

    resources :control_valve_sizings do
      collection do
        get 'get_stream_values'
        get 'get_discharge_stream_nos'
        get 'control_valve_sizing_summary'
        get 'bypass_design_calculation'
        get 'control_valve_design_calculation'
        get 'upstream_calculate'
        get 'downstream_calculate'
      end
      member do
        get 'clone'
      end
    end

    resources :flow_element_sizings do
      collection do
        get 'get_stream_values'
        get 'get_discharge_stream_nos'
        get 'flow_element_sizing_summary'
        get 'upstream_calculate'
        get 'downstream_calculate'
        get 'get_pipe_diameter'
        get 'get_orifice_types'
        get 'orifice_design'
      end
      member do
        get 'clone'
      end
    end

    resources :storage_tank_sizings do
      collection do
        get 'get_stream_values'
        get 'store_tank_sizing_summary'
        get 'design_conditions_calculate'
        get 'atm_low_pressure_storage_calculate'
        get 'pvapor_calculate'
        get 'pressure_storage_calculate'
        get 'mechanical_design_calculate'
        get 'atm_standardize_calculate'
        get 'ps_standardize_calculate'
      end
      member do
        get 'clone'
      end
    end

    resources :column_sizings do
      collection do
        get 'get_stream_values'
        get 'column_sizing_summary'
        get 'system_definition_calculation'
        get 'minimum_column_stages_calculation'
        get 'minimum_column_stages_winn_modified_calculation'
        post 'minimum_reflux_ratio_calculation'
      end
      member do
        get 'clone'
      end
    end

    resources :heat_exchanger_sizings do
      collection do
        get 'get_stream_values'
        get 'heat_exchanger_sizing_summary'
        get 'change_tube_od'
      end
      member do
        get 'clone'
      end
    end

    resources :relief_device_sizings do
      collection do
        get "scenario_identification"
        post "update_scenario_identification"
        get "get_stream_values"
        get "get_discharge_coefficient"
        get "reset_relief_design"
      end
      member do
        get "set_pressure_system_description"
        post "save_system_description"
        get "refresh_system_description"
        get "new_scenario_summary"
        get "delete_scenario_summary"
        get "cal_pressure_relief"
        get "validate_pressure_relief"
        get "cal_rupture_disk"
        get "validate_rupture_disk"
        get "cal_open_vent_disk"
        get "validate_open_vent"
        get "select_low_pressure_vent"
      end

      get "equipments"
      get "equipment_section"
      get "design_pressure"
      get "analyze"
      get "relief_devices"
      get "locations"
      get "rupture_disks"
      get "rupture_locations"
      get "open_vent_relief_devices"
      get "open_vent_locations"
      get "low_pressure_vent_relief_devices"
      get "relief_valve_orificearea"
      get "design_summary"

    end
    resources :item_types_transmit_and_proposals do
      collection do
        get "sizing_data"
        get "engineering_data_form"
        post "electronic_data_new"
        put "electronic_data_update"
        get "bid_evaluation"
      end
    end

    resources :procure_items do
      collection do
        get "procure_item_purchase_items"
      end
    end

    resources :vendor_lists
    resources :process_units
    resources :user_project_settings
    resources :sizings
  end

  match "superadmin", :to => 'superadmin#index', :as => :superadmin_home

  namespace :superadmin do
    resources :measure_units do
      collection do
        get 'get_measurement_sub_types'
      end
    end
    resources :measurement_sub_types
    resources :measurements
    resources :companies
  end

  root :to => "home#index"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
