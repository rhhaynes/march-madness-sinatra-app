module BracketHttpRequestControllers

  # get "/brackets/new"
  def create_new_form_logic
    determine_bracket_status
    create_viewer_logic
  end

  # post "/brackets"
  def process_new_form_logic(params)
    logic = bundle_logic_from_params(params)
    update_games_from_logic(logic)
    create_games_from_logic(logic)
    create_viewer_logic
  end

  # get "/brackets/:id"
  def create_bracket_display
    create_table_for_regional_rounds
    create_table_for_final_rounds
  end

  # get "/brackets/:id/edit"
  def create_edit_form_logic
    create_viewer_logic
  end

  # patch "/brackets/:id"
  def process_edit_form_logic(params)
    logic = bundle_logic_from_params(params)
    destroy_games_to_edit
    update_games_from_logic(logic)
    create_games_from_logic(logic)
    create_viewer_logic
  end

end
