class AddTargetTwoPhaseToLineSizing < ActiveRecord::Migration
  def self.up
   add_column :line_sizings, :target_two_phase_flow_regime, :string
  end

  def self.down
    remove_column :line_sizings, :target_two_phase_flow_regime
  end
end
