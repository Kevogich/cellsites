class StaticData < ActiveRecord::Base

  #ref list16 Calculation Method
  def self.calculation_method
    ["Liquid Fire",
     "Vapor Fire",
     "Low Pressure Fire",
     "Hydraulic Expansion",
     "Control Valve Failure",
     "Tube Rupture",
     "Orifice Flow",
     "Pipe Capacity",
     "Generic",
     "Inbreathing",
     "Outbreathing"]
  end

  #ref list22 Discharge Locations
  def self.discharge_location
    ["Pressurized Collection System",
     "Non-Pressurized Collection System",
     "Atmosphere",
     "Pressurized Process Equipment",
     "Non-Pressurized Process Equipment",
     "Pump Suction"
    ]
  end

  #ref list23 Flange Type
  def self.flange_type
    ["FF",
     "RF",
     "RJF",
     "T&G",
     "Thd",
     "Others"
    ]
  end

  #ref list24 PSV Type
  def self.psv_type
    ["Conventional",
     "Balanced Bellow",
     "Pilot Operated"
    ]
  end

  #ref list25 PSV Sub Type
  def self.psv_subtype
    ["Safety",
     "Safety Relief",
     "Relief"
    ]
  end

  #ref list26 Standard Body Size
  def self.standard_bodysize
    ["3/4'' x 1''",
     "1'' x 2''",
     "1 1/2'' x 2''",
     "1 1/2'' x 2 1/2''",
     "1 1/2'' x 3''",
     "2'' x 3''",
     "2 1/2'' x 3''",
     "3'' x 4''",
     "4'' x 6''",
     "6'' x 8''",
     "6'' x 10''",
     "8'' x 10''"
    ]
  end

  #ref list27 Relief Phase
  def self.relief_phase
    ["Liquid",
     "Vapor",
     "Two Phase"
    ]
  end

  #ref list28 Low Pressure Tank Code
  def self.low_pressure_tank_code
    ["API 620",
    "API 650",
    "Other"
    ]
  end

  #ref list31 Low Pressure Vent Discharge Location
  def self.low_pressure_discharge_loc
    ["Atmosphere",
     "Pipe Away"
    ]
  end

  #ref list32 Emission Standards
  def self.emission_standards
    ["Strict",
     "Regular"
    ]
  end

  #ref list34 Protection Type
  def self.protection_type
    ["Open Vent",
     "Conservation Vent",
     "Emergency Vent"
    ]
  end

  #ref list15 Scenario
  def self.scenario
    ["",
     "Abnormal Heat Input or Vapor Input",
     "Accumulation of Noncondensables",
     "Atmospheric Pressure Change",
     "Blocked Discharge",
     "Change in Input Stream Temperature",
     "Check Valve Failure",
     "Check Valve Leak",
     "Chemical Reaction",
     "Closed Outlets On Vessel",
     "Cooling Failure To Condenser",
     "Entrance of Highly Volatile Material",
     "External Fire - Equipment",
     "External Fire - System",
     "External Fire - Global",
     "External Heat Transfer Device Failure",
     "Failure of Automatic Controls",
     "Heat Exchanger Tube Rupture",
     "Heat Exchanger Tube Leak",
     "Heat Inleak",
     "Hydraulic Expansion",
     "Inadvertent Valve Opening",
     "Inbreathing",
     "Inert Pad and Purges Failure",
     "Internal Explosion",
     "Internal Heat Transfer Device Failure",
     "Lean Oil Failure to Absorber",
     "Loss of Heat in Series Fractionation",
     "Mechanical Failure",
     "Operator Error",
     "Others",
     "Outbreathing",
     "Overfilling ",
     "Pressure Transfer Blowoff",
     "Loss of Pump Recycle",
     "Side-Stream Reflux Failure",
     "Steam Out",
     "Top-Tower Reflux Failure",
     "Transient Pressure Surges - Water",
     "Transient Pressure Surges - Steam",
     "Uninsulated Tank",
     "Utility Failure - Cooling Water",
     "Utility Failure - Electric Power",
     "Utility Failure - Fuel Gas",
     "Utility Failure - Inert Gas",
     "Utility Failure - Instrument Air",
     "Utility Failure - Others",
     "Utility Failure - Steam",
     "Vent Treatment System"
    ]
  end

  #ref list14 Documentation By
  def self.documentation_by
    ["Software",
     "Process Engineer",
     "Reviewer",
     "Client"]
  end

  #ref list11 Pipe Schedule
  def self.pipe_schedule
    ["Sch. 20", "Sch. 30", "Sch. 40", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160"]
  end

  #ref list10 Orifice Designation
  def self.orifice_designation
    [
      ['D','D'],
      ['E','E'],
      ['F','F'],
      ['G','G'],
      ['H','H'],
      ['J','J'],
      ['L','L'],
      ['K','K'],
      ['M','M'],
      ['N','N'],
      ['P','P'],
      ['Q','Q'],
      ['R','R'],
      ['T','T'],
      ['T2','T<sub>2<sub>'],
      ['V','V'],
      ['W','W'],
      ['Y','Y'],
      ['Z','Z'],
      ['Z2','Z<sub>2<sub>'],
      ['AA','AA'],
      ['BB','BB'],
      ['BB2','BB<sub>2<sub>']
    ]
  end

  ##get Orifice Area based on designation
  def self.rv_orificearea
    {
        "D" => "0.110",
        "E" => "0.196",
        "F" => "0.307",
        "G" => "0.503",
        "H" => "0.785",
        "J" => "1.287",
        "L" => "1.838",
        "K" => "2.853",
        "M" => "3.600",
        "N" => "4.340",
        "P" => "6.380",
        "Q" => "11.050",
        "R" => "16.000",
        "T" => "26.000",
        "T2" => "27.870",
        "V" => "42.190",
        "W" => "60.750",
        "Y" => "82.680",
        "Z" => "90.950",
        "Z2" => "108.860",
        "A" => "136.690",
        "B" => "168.740",
        "BB2" => "185.000"
    }
  end

  #ref list9 Kd Option
  def self.kd_option
    ["API 2000 4.6.1.2.3", "Manufacturer", "Estimated"]
  end

  #ref list8 Kp Option
  def self.kp_option
    ["API 520 Fig. 37", "Manufacturer", "Estimated"]
  end

  #ref list7 Kw Option
  def self.kw_option
    ["API 520 Fig. 31", "Manufacturer", "Estimated"]
  end

  #ref list6 Kb Option
  def self.kb_option
    ["API 520 Fig. 30", "Manufacturer", "Estimated"]
  end

  #ref list5 No of Access Opening
  def self.no_of_access_opening
    %w(0 1 2 3 4)
  end

  #ref list4 Pipe Size
  def self.pipe_size(cf = 1, d = 4)
    arr =
      [{:id => 1, :name => "&frac14;", :value => 0.25},
       {:id => 2, :name => "&frac12;", :value => 0.5},
       {:id => 3, :name => "&frac34;", :value => 0.75},
       {:id => 4, :name => "1", :value => 1.0},
       {:id => 5, :name => "1&frac14;", :value => 1.25},
       {:id => 6, :name => "1&frac12;", :value => 1.5},
       {:id => 7, :name => "2", :value => 2.0},
       {:id => 8, :name => "2&frac12;", :value => 2.5},
       {:id => 9, :name => "3", :value => 3.0},
       {:id => 10, :name => "3&frac12;", :value => 3.5},
       {:id => 11, :name => "4", :value => 4.0},
       {:id => 12, :name => "5", :value => 5.0},
       {:id => 13, :name => "6", :value => 6.0},
       {:id => 14, :name => "8", :value => 8.0},
       {:id => 15, :name => "10", :value => 10.0},
       {:id => 16, :name => "12", :value => 12.0},
       {:id => 17, :name => "14", :value => 14.0},
       {:id => 18, :name => "16", :value => 16.0},
       {:id => 19, :name => "18", :value => 18.0},
       {:id => 20, :name => "20", :value => 20.0},
       {:id => 21, :name => "22", :value => 22.0},
       {:id => 22, :name => "24", :value => 24.0},
       {:id => 23, :name => "26", :value => 26.0},
       {:id => 24, :name => "28", :value => 28.0},
       {:id => 25, :name => "30", :value => 30.0},
       {:id => 26, :name => "32", :value => 32.0},
       {:id => 27, :name => "34", :value => 34.0},
       {:id => 28, :name => "36", :value => 36.0},
       {:id => 29, :name => "48", :value => 48.0},
       {:id => 30, :name => "56", :value => 56.0},
       {:id => 31, :name => "72", :value => 72.0}
      ]
    if cf == 1
      arr
    else
      arr.each do |a|
        a[:name] = (cf * a[:value]).round(d)
        a[:value] = (cf * a[:value]).round(d)
      end
    end
  end

  #ref list3
  def self.fire_level_basis
    ['LLL', 'NLL', 'HLL', 'HLA SP']
  end

  #ref list2
  def self.fill_time_basis
    ['Bottom', 'LLL', 'NLL', 'HLL', 'HLA SP', 'Top']
  end

  #ref list1
  def self.yes_no
    %w(Yes No)
  end

  def self.material_group
    %W(1.1 1.2 1.3 1.4 1.5 1.7 1.9 1.10 1.11 1.13 1.14 1.15 1.17 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 2.10 2.11 2.12 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10 3.11 3.12 3.13 3.14 3.15 3.16 3.17)
  end

  def self.material_designation
    {
      "" => [],
      "1.1" => ["C-Si", "C-Mn-Si", "C-Mn-Si-V", "31/2 Ni"],
      "1.2" => ["C-Mn-Si", "C-Mn-Si-V", "21/2Ni", "31/2Ni"],
      "1.3" => ["C-Si", "C-Mn-Si", "2 1/2Ni", "3 1/2Ni", "C-1/2Mo"],
      "1.4" => ["C-Si", "C-Mn-Si"],
      "1.5" => ["C-1/2Mo"],
      "1.7" => ["1/2Cr-1/2Mo", "Ni-1/2Cr-1/2Mo", "3/4Ni-3/4Cr-1Mo"],
      "1.9" => ["11/4Cr-1/2Mo", "11/4Cr-1/2Mo-Si"],
      "1.10" => ["2 1/4Cr-1Mo"],
      "1.11" => ["C-1/2Mo"],
      "1.13" => ["5Cr-1/2Mo"],
      "1.14" => ["9Cr-1M0"],
      "1.15" => ["9Cr-1M0-V"],
      "1.17" => ["1Cr-1/2Mo", "5Cr-1/2Mo"],
      "2.1" => ["18Cr-8Ni"],
      "2.2" => ["16Cr-12Ni-2Mo", "18Cr-13Ni-3Mo", "19Cr-10Ni-3Mo"],
      "2.3" => ["18Cr-8Ni", "16Cr-12Ni-2Mo", "18Cr-13Ni-3Mo"],
      "2.4" => ["18Cr-10Ni-Ti"],
      "2.5" => ["18Cr-10Ni-Cb"],
      "2.6" => ["23Cr-12Ni"],
      "2.7" => ["25Cr-20Ni"],
      "2.8" => ["20Cr-18Ni-6Mo", "22Cr-5Ni-3Mo-N", "25Cr-7Ni-4Mo-N", "24Cr-10Ni-4Mo-V", "25Cr-5Ni-2Mo-3Cu", "25Cr-7Ni-3.5Mo-W-Cb", "25Cr-7Ni-3.5Mo-N-Cu-W"],
      "2.9" => ["23Cr-12Ni", "25Cr-20Ni"],
      "2.10" => ["25Cr-12Ni"],
      "2.11" => ["18Cr-10Ni-Cb"],
      "2.12" => ["25Cr-20Ni"],
      "3.1" => ["35Ni-35Fe-10Cr-Cb"],
      "3.2" => ["99.0Ni"],
      "3.3" => ["99.0Ni-Low C"],
      "3.4" => ["67Ni-30Cu", "67Ni-30Cu-S"],
      "3.5" => ["72Ni-15Cr-8Fe"],
      "3.6" => ["33Ni-42Fe-21Cr"],
      "3.7" => ["65Ni-28Mo-2Fe", "64Ni-29.5Mo-2Cr-2Fe-Mn-W"],
      "3.8" => ["54Ni-16Mo-15Cr", "60Ni-22Cr-9Mo-3.5Cb", "62Ni-28Mo-5Fe", "70Ni-16Mo-7Cr-5Fe", "61Ni-16Mo-16Cr", "42Ni-21.5Cr-3Mo-2.3Cu", "55Ni-21Cr-13.5Mo", "55Ni-23Cr-16Mo-1.6Cu"],
      "3.9" => ["47Ni-22Cr-9Mo-I8Fe"],
      "3.10" => ["25Ni-46Fe-21Cr-5Mo"],
      "3.11" => ["44Fe-25Ni-21Cr-Mo"],
      "3.12" => ["26Ni-43Fe-22Cr-5Mo", "47Ni-22Cr-20Fe-7Mo", "46Fe-24Ni-21Cr-6Mo-Cu-N"],
      "3.13" => ["49Ni-25Cr-18Fe-6Mo", "Ni-Fe-Cr-Mo-Cu-Low C"],
      "3.14" => ["47Ni-22Cr-19Fe-6Mo", "40Ni-29Cr-15Fe-5Mo"],
      "3.15" => ["33Ni-42Fe-21Cr"],
      "3.16" => ["35Ni-19Cr-11/4S"],
      "3.17" => ["29Ni-20.5Cr-3.5Cu-2.5Mo"],
    }
  end

  def self.get_material_designation(material_group)
    return [] if material_designation[material_group].nil?
    material_designation[material_group]
  end

  def self.segment_type
    ["Line",
     "Source",
     "Destination",
     "Centrifugal Pump",
     "Reciprocating Pump",
     "Centrifugal Comp.",
     "Reciprocating Comp.",
     "Steam Turbine",
     "Hydraulic Turbine",
     "Turbo Expander",
     "Vessel",
     "Tank",
     "Column",
     "Heat Exchanger",
     "Other Equipment",
     "Control Valve",
     "Flow Element",
     "Pressure Relief Device",
     "Branch",
     "Joint",
     "Reb - Vert N to N",
     "Reb - Vert Below N",
     "Reb - Horiz",
     "Reb - Kettle",
     "Single Segment Calc"]
  end

  def self.flange_classes
    ["75",
     "150",
     "300",
     "400",
     "600",
     "900",
     "1500",
     "2500"]
  end

  def self.flange_facing
    ["FF",
     "RF",
     "RJF",
     "T&G",
     "Thd"]
  end

  def self.insulation_type
    [
      "Frost & Personnel Protection",
      "Cold Anticondensation",
      "Heat Conservation",
      "Fireproof",
      "Process Temperature Control",
      "Other"
    ]
  end

  def self.equipment_type
    ["Centrifugal Pump",
     "Reciprocating Pump",
     "Centrifugal Compressor",
     "Reciprocating Compressor"]
  end

  def self.equipment_tag
    []
  end

  def self.turbine_type
    ["Single Stage, Single Valve",
     "Single Stage, Multiple Valves",
     "Multi-Stage, Single Valve",
     "Multi-Stage, Multiple Valves"]
  end

  def self.stream_phase
    ["Liquid",
     "Vapor",
     "Bi-Phase"]
  end

  def self.head_type
    ['Ellipsoidal',
     'Torispherical',
     'Hemispherical',
     'Flat',
     'Conical',
     'Domed',
     'Umbrella',
     'None']
  end

  def self.orientation
    ["Horizontal",
     "Vertical",
     "Spherical",
     "Spheroidal"]
  end

  def self.shell_tube_pass
    ["1-1",
     "1-2",
     "1-4",
     "1-6",
     "1-8",
     "2-4",
     "2-8",
     "3-6"]
  end

  def self.tube_material
    ["Aluminum, 3003 Tempered",
     "Carbon Steel",
     "Cabon Moly (&frac12;%) Steel",
     "2&frac14; Cr, 1 Mo Steel",
     "13 Cr",
     "304 Stainless Steel",
     "Admiralty",
     "Copper",
     "90-10 CuNi",
     "70-30 CuNi",
     "Nickel 200",
     "NiFeCrMoCu (Alloy 825)",
     "Titanium"]
  end

  def self.tube_pitch
    ["Triangular (30&deg;)",
     "Rotated Triangular (60&deg;)",
     "Square (90&deg;)",
     "Rotated Square (45&deg;)"]
  end

  def self.motor_type
    ["Induction (Squirrel-Cage)",
     "Induction (Wound Rotor)",
     "Synchronous",
     "Direct Current"]
  end

  def self.enclosure
    ["Open Drip Proof",
     "Explosion Proof",
     "Weather Protected Type I",
     "Weather Protected Type II",
     "Totally Enclosed Forced Ventilation (TEFV)",
     "Totally Enclosed Fan Cooled (TEFC)",
     "Totally Enclosed Water to Air Cooled (TEWAC)"]
  end

  def self.time_rating
    ["Continuous",
     "Short-Term",
     "Intermittent"]
  end

  def self.mounting
    ["Horizontal",
     "Vertical"]
  end

  def self.flow_regime
    ["",
     "Stratified",
     "Bubble/Froth",
     "Slug",
     "Wave",
     "Annular",
     "Dispersed/Spray/Mist",
     "Plug"]
  end

  def self.hp
    [
      {:name => "&frac12;", :value => 0.5},
      {:name => "&frac34;", :value => 0.75},
      {:name => "1&frac12;", :value => 1.5},
      {:name => "2", :value => 2.0},
      {:name => "3", :value => 3.0},
      {:name => "5", :value => 5.0},
      {:name => "7&frac12;", :value => 7.5},
      {:name => "10", :value => 10.0},
      {:name => "15", :value => 15.0},
      {:name => "20", :value => 20.0},
      {:name => "25", :value => 25.0},
      {:name => "30", :value => 30.0},
      {:name => "40", :value => 40.0},
      {:name => "50", :value => 50.0},
      {:name => "60", :value => 60.0},
      {:name => "75", :value => 75.0},
      {:name => "100", :value => 100.0},
      {:name => "125", :value => 125.0},
      {:name => "150", :value => 150.0},
      {:name => "200", :value => 200.0},
      {:name => "250", :value => 250.0},
      {:name => "300", :value => 300.0},
      {:name => "350", :value => 350.0},
      {:name => "400", :value => 400.0},
      {:name => "450", :value => 450.0},
      {:name => "500", :value => 500.0},
      {:name => "600", :value => 600.0},
      {:name => "700", :value => 700.0},
      {:name => "800", :value => 800.0},
      {:name => "900", :value => 900.0},
      {:name => "1000", :value => 1000.0},
      {:name => "1250", :value => 1250.0},
      {:name => "1500", :value => 1500.0},
      {:name => "1750", :value => 1750.0},
      {:name => "2000", :value => 2000.0},
      {:name => "2250", :value => 2250.0},
      {:name => "2500", :value => 2500.0},
      {:name => "3000", :value => 3000.0},
      {:name => "3500", :value => 3500.0},
      {:name => "4000", :value => 4000.0},
      {:name => "4500", :value => 4500.0},
      {:name => "5000", :value => 5000.0},
      {:name => "5500", :value => 5500.0},
      {:name => "6000", :value => 6000.0},
      {:name => "6500", :value => 6500.0},
      {:name => "7000", :value => 7000.0},
      {:name => "7500", :value => 7500.0},
      {:name => "8000", :value => 8000.0},
      {:name => "8500", :value => 8500.0},
      {:name => "9000", :value => 9000.0},
      {:name => "9500", :value => 9500.0},
      {:name => "10000", :value => 10000.0},
      {:name => "10500", :value => 10500.0},
      {:name => "11000", :value => 11000.0},
      {:name => "11500", :value => 11500.0},
      {:name => "12000", :value => 12000.0},
      {:name => "12500", :value => 12500.0},
      {:name => "13000", :value => 13000.0},
      {:name => "13500", :value => 13500.0},
      {:name => "14000", :value => 14000.0},
      {:name => "14500", :value => 14500.0},
      {:name => "15000", :value => 15000.0},
      {:name => "15500", :value => 15500.0},
      {:name => "16000", :value => 16000.0},
      {:name => "16500", :value => 16500.0},
      {:name => "17000", :value => 17000.0},
      {:name => "17500", :value => 17500.0},
      {:name => "18000", :value => 18000.0},
      {:name => "18500", :value => 18500.0},
      {:name => "19000", :value => 19000.0},
      {:name => "19500", :value => 19500.0},
      {:name => "20000", :value => 20000.0},
      {:name => "20500", :value => 20500.0},
      {:name => "21000", :value => 21000.0},
      {:name => "21500", :value => 21500.0},
      {:name => "22000", :value => 22000.0},
      {:name => "22500", :value => 22500.0},
      {:name => "23000", :value => 23000.0},
      {:name => "23500", :value => 23500.0},
      {:name => "24000", :value => 24000.0},
      {:name => "24500", :value => 24500.0},
      {:name => "25000", :value => 25000.0},
      {:name => "25500", :value => 25500.0},
      {:name => "26000", :value => 26000.0},
      {:name => "26500", :value => 26500.0},
      {:name => "27000", :value => 27000.0},
      {:name => "27500", :value => 27500.0},
      {:name => "28000", :value => 28000.0},
      {:name => "28500", :value => 28500.0},
      {:name => "29000", :value => 29000.0},
      {:name => "29500", :value => 29500.0},
      {:name => "30000", :value => 30000.0}
    ]
  end

  def self.valve_type
    ["",
     "Gate",
     "Ball",
     "Globe",
     "Butterfly",
     "Angle (45&deg;)",
     "Angle (90&deg;)",
     "Plug (Branch Flow)",
     "Plug (Straight Thru)",
     "Plug (3-Way)",
     "Diaphragm"]
  end

  def self.chemicals
    ['user entered',
     'carbon-tetrachloride',
     'trichlorofluoromethane',
     'dichlorodifluoromethane',
     'chlorotrifluoromethane',
     'carbon-tetrafluoride',
     'carbon-monoxide',
     'carbon-dioxide',
     'carbonyl-sulfide',
     'carbon-disulfide',
     'chloroform',
     'dichlorofluoromethane',
     'chlorodifluoromethane',
     'trifluoromethane',
     'triiodomethane',
     'isothiocyanic-acid',
     'dichloromethane',
     'chlorofluoromethane',
     'difluoromethane',
     'diiodomethane',
     'formaldehyde',
     'formic-acid',
     'bromomethane',
     'chloromethane',
     'fluoromethane',
     'iodomethane',
     'nitromethane',
     'methyl-nitrite',
     'methyl-nitrate',
     'methane',
     'methanol',
     'methanethiol',
     'methylamine',
     'tetrachloroethene',
     'hexachloroethane',
     '112trichlorotrifluoroethane',
     '12dichlorotetrafluoroethane',
     'chloropentafluoroethane',
     'tetrafluoroethene',
     'hexafluoroethane',
     'cyanogen',
     'trichloroethene',
     'pentachloroethane',
     'trifluoroethene',
     'acetylene(ethyne)',
     '1,1-dichloroethene',
     'cis-1,2-dichloroethene',
     'trans-1,2-dichloroethene',
     '1,1,2,2-tetrachloroethane',
     '1,1-difluoroethene',
     'cis-1,2-difluoroethene',
     'trans-1,2-difluoroethene',
     'ketene',
     'bromoethylene',
     'chloroethene',
     '1,1,2-trichloroethane',
     'acetyl-chloride',
     'fluoroethene',
     '1,1,1-trifluoroethane',
     'acetonitrile',
     'ethylene',
     '1,2-dibromoethane',
     '1,1-dichloroethane',
     '1,2-dichloroethane',
     '1,1-difluoroethane',
     '1,2-diiodoethane',
     'ethylene-oxide',
     'acetaldehyde',
     'acetic-acid',
     'methyl-formate',
     'thioacetic-acid',
     'thiacyclopropane',
     'bromoethane',
     'chloroethane',
     'fluoroethane',
     'iodoethane',
     'ethylenimine',
     'nitroethane',
     'ethyl-nitrate',
     'ethane',
     'methyl-ether',
     'ethyl-alcohol',
     'ethylene-glycol',
     'methyl-sulfide',
     'ethanethiol',
     'methyl-disulfide',
     'ethylamine',
     'dimethylamine',
     'acrylonitrile',
     'allene(propadiene)',
     'propyne(methylacetylene)',
     'acrylic-acid',
     '3-bromo-1-propene',
     '3-chloro-1-propene',
     '1,2,3-trichloropropane',
     '3-iodo-1-propene',
     'propionitrile',
     'propene',
     'cyclopropane',
     '1,2-dibromopropane',
     '1,2-dichloropropane',
     '1,3-dichloropropane',
     '2,2-dichloropropane',
     '1,2-diiodopropane',
     'propylene-oxide',
     'allyl-alcohol',
     'propionaldehyde',
     'acetone',
     'thiacyclobutane',
     '1-bromopropane',
     '2-bromopropane',
     '1-chloropropane',
     '2-chloropropane',
     '1-fluoropropane',
     '2-fluoropropane',
     '1-iodopropane',
     '2-iodopropane',
     '1-nitropropane',
     '2-nitropropane',
     'propyl-nitrate',
     'isopropyl-nitrate',
     'propane',
     'ethyl-methyl-ether',
     'propyl-alcohol',
     'isopropyl-alcohol',
     'ethyl-methyl-sulfide',
     '1-propanethiol',
     '2-propanethiol',
     'propylamine',
     'trimethylamine',
     'octafluorocyclobutane',
     'butadiyne(biacetylene)',
     '1buten3yne(vinylacetylene)',
     'furan',
     'thiophene',
     '1,2-butadiene',
     '1,3-butadiene',
     '1-butyne(ethylacetylene)',
     '2-butyne(dimethylacetylene)',
     'cyclobutene',
     'acetic-anhydride',
     'butyronitrile',
     'isobutyronitrile',
     '1-butene',
     '2-butene,cis',
     '2-butene,trans',
     '2-methylpropene',
     'cyclobutane',
     '1,2-dibromobutane',
     '2,3-dibromobutane',
     '1,2-diiodobutane',
     'butyraldehyde',
     '2-butanone',
     'p-dioxane',
     'ethyl-acetate',
     'thiacyclopentane',
     '1-bromobutane',
     '2-bromobutane',
     '2-bromo-2-methylpropane',
     '1-chlorobutane',
     '2-chlorobutane',
     '1-chloro-2-methylpropane',
     '2-chloro-2-methylpropane',
     '2-iodo-2-methylpropane',
     'pyrrolidine',
     '1-nitrobutane',
     '2-nitrobutane',
     'butane',
     '2-methylpropane(isobutane)',
     'ethyl-ether',
     'methyl-propyl-ether',
     'methyl-isopropyl-ether',
     'butyl-alcohol',
     'sec-butyl-alcohol',
     'tert-butyl-alcohol',
     'ethylsulfide',
     'isopropyl-methyl-sulfide',
     'methyl-propyl-sulfide',
     '1-butanethiol',
     '2-butanethiol',
     '2-methyl-1-propanethiol',
     '2-methyl-2-propanethiol',
     'ethyl-disulfide',
     'butylamine',
     'sec-butylamine',
     'tert-butylamine',
     'diethylamine',
     'pyridine',
     '2-methylthiophene',
     '3-methylthiophene',
     '1,2-pentadiene',
     '1,3-pentadiene,cis',
     '1,3-pentadiene,trans',
     '1,4-pentadiene',
     '2,3-pentadiene',
     '3-methyl-1,2-butadiene',
     '2-methyl-1,3-butadiene',
     '1-pentyne',
     '2-pentyne',
     '3-methyl-1-butyne',
     'cyclopentene',
     'spiropentane',
     '1-pentene',
     '2-pentene,cis',
     '2-pentene,trans',
     '2-methyl-1-butene',
     '3-methyl-1-butene',
     '2-methyl-2-butene',
     'cyclopentane',
     '2,3-dibromo-2-methylbutane',
     'valeraldehyde',
     '2-pentanone',
     'thiacyclohexane',
     'cyclopentanethiol',
     '1-bromopentane',
     '1-chloropentane',
     '1-chloro-3-methylbutane',
     '2-chloro-2-methylbutane',
     'pentane',
     '2-methylbutane(isopentane)',
     '2,2-dimethypropane',
     'methyl-tert-butyl-ether',
     'pentyl-alcohol',
     'tert-pentyl-alcohol',
     'butyl-methyl-sulfide',
     'ethyl-propyl-sulfide',
     '2-methyl-2-butanethiol',
     '1-pentanethiol',
     'hexachlorobenzene',
     'hexafluorobenzene',
     'o-dichlorobenzene',
     'm-dichlorobenzene',
     'p-dichlorobenzene',
     'm-difluorobenzene',
     'o-difluorobenzene',
     'p-difluorobenzene',
     'bromobenzene',
     'chlorobenzene',
     'fluorobenzene',
     'iodobenzene',
     'benzene',
     'phenol',
     'benzenethiol',
     '2-picoline',
     '3-picoline',
     'aniline',
     '1-hexyne',
     'cyclohexene',
     '1-methylcyclopentene',
     '3-methylcyclopentene',
     '4-methylcyclopentene',
     'cyclohexanone',
     '1-hexene',
     '2-hexene,cis',
     '2-hexene,trans',
     '3-hexene,cis',
     '3-hexene,trans',
     '2-methyl-1-pentene',
     '3-methyl-1-pentene',
     '4-methyl-1-pentene',
     '2-methyl-2-pentene',
     '3-methyl-2-pentene,cis',
     '3-methyl-2-pentene,trans',
     '4-methyl-2-pentene,cis',
     '4-methyl-2-pentene,trans',
     '2-ethyl-1-butene',
     '2,3-dimethyl-1-butene',
     '3,3-dimethyl-1-butene',
     '2,3-dimethyl-2-butene',
     'cyclohexane',
     'methylcyclopentane',
     'cyclohexanol',
     'hexanal',
     'thiacycloheptane',
     'hexane',
     '2-methylpentane',
     '3-methylpentane',
     '2,2-dimethylbutane',
     '2,3-dimethylbutane',
     'propyl-ether',
     'isopropyl-ether',
     'hexyl-alcohol',
     'butyl-ethyl-sulfide',
     'isopropyl-sulfide',
     'methyl-pentyl-sulfide',
     'propyl-sulfide',
     '1-hexanethiol',
     'propyl-disulfide',
     'triethylamine',
     'a,a,a-trifluorotoluene',
     'benzonitrile',
     'benzoic-acid',
     'p-fluorotoluene',
     'toluene',
     '1,3,5-cycloheptatriene',
     'm-cresol',
     'o-cresol',
     'p-cresol',
     '1-heptyne',
     '1-heptene',
     'cycloheptane',
     'ethylcyclopentane',
     '1,1-dimethylcyclopentane',
     'c-1,2-dimethylcyclopentane',
     't-1,2-dimethylcyclopentane',
     'c-1,3-dimethylcyclopentane',
     't-1,3-dimethylcyclopentane',
     'methylcyclohexane',
     'heptanal',
     'heptane',
     '2-methylhexane',
     '3-methylhexane',
     '3-ethylpentane',
     '2,2-dimethylpentane',
     '2,3-dimethylpentane',
     '2,4-dimethylpentane',
     '3,3-dimethylpentane',
     '2,2,3-trimethylbutane',
     'isopropyl-tert-butyl-ether',
     'heptyl-alcohol',
     'butyl-propyl-sulfide',
     'ethyl-pentyl-sulfide',
     'hexyl-methyl-sulfide',
     '1-heptanethiol',
     'ethynylbenzene',
     'styrene',
     '1,3,5,7-cyclooctatetraene',
     'ethylbenzene',
     'm-xylene',
     'o-xylene',
     'p-xylene',
     '1-octyne',
     '1-octene',
     'cyclooctane',
     'propylcyclopentane',
     'ethylcyclohexane',
     '1,1-dimethylcyclohexane',
     'c-1,2-dimethylcyclohexane',
     't-1,2-dimethylcyclohexane',
     'c-1,3-dimethylcyclohexane',
     't-1,3-dimethylcyclohexane',
     'c-1,4-dimethylcyclohexane',
     't-1,4-dimethylcyclohexane',
     'octanal                    1',
     'octane',
     '2-methylheptane',
     '3-methylheptane',
     '4-methylheptane',
     '3-ethylhexane',
     '2,2-dimethylhexane',
     '2,3-dimethylhexane',
     '2,4-dimethylhexane',
     '2,5-dimethylhexane',
     '3,3-dimethylhexane',
     '3,4-dimethylhexane',
     '3-ethyl-2-methylpentane',
     '3-ethyl-3-methylpentane',
     '2,2,3-trimethylpentane',
     '2,2,4-trimethylpentane',
     '2,3,3-trimethylpentane',
     '2,3,4-trimethylpentane',
     '2,2,3,3-tetramethylbutane',
     'butyl-ether',
     'sec-butyl-ether',
     'tert-butyl-ether',
     'octyl-alcohol',
     'butyl-sulfide',
     'ethyl-hexyl-sulfide',
     'heptyl-methyl-sulfide',
     'pentyl-propyl-sulfide',
     '1-octanethiol',
     'butyl-disulfide',
     'alpha-methylstyrene',
     'propenylbenzene,cis',
     'propenylbenzene,trans',
     'm-methylstyrene',
     'o-methylstyrene',
     'p-methylstyrene',
     'propylbenzene',
     'cumene',
     'm-ethyltoluene',
     'o-ethyltoluene',
     'p-ethyltoluene',
     '1,2,3-trimethylbenzene',
     '1,2,4-trimethylbenzene',
     'mesitylene',
     '1-nonyne',
     '1-nonene',
     'butylcyclopentane',
     'propylcyclohexane',
     'c-c-135trimethylcyclohexane',
     'c-t-135trimethylcyclohexane',
     'nonanal',
     'nonane',
     '2-methyloctane',
     '3-methyloctane',
     '4-methyloctane',
     '3-ethylheptane',
     '4-ethylheptane',
     '2,2-dimethylheptane',
     '2,3-dimethylheptane',
     '2,4-dimethylheptane',
     '2,5-dimethylheptane',
     '2,6-dimethylheptane',
     '3,3-dimethylheptane',
     '3,4-dimethylheptane',
     '3,5-dimethylheptane',
     '4,4-dimethylheptane',
     '3-ethyl-2-methylhexane',
     '4-ethyl-2-methylhexane',
     '3-ethyl-3-methylhexane',
     '3-ethyl-4-methylhexane',
     '2,2,3-trimethylhexane',
     '2,2,4-trimethylhexane',
     '2,2,5-trimethylhexane',
     '2,3,3-trimethylhexane',
     '2,3,4-trimethylhexane',
     '2,3,5-trimethylhexane',
     '2,4,4-trimethylhexane',
     '3,3,4-trimethylhexane',
     '3,3-diethylpentane',
     '3-ethyl-2,2-dimethylpentane',
     '3-ethyl-2,3-dimethylpentane',
     '3-ethyl-2,4-dimethylpentane',
     '2,2,3,3-tetramethylpentane',
     '2,2,3,4-tetramethylpentane',
     '2,2,4,4-tetramethylpentane',
     '2,3,3,4-tetramethylpentane',
     'nonyl-alcohol',
     'butyl-pentyl-sulfide',
     'ethyl-heptyl-sulfide',
     'hexyl-propyl-sulfide',
     'methyl-octyl-sulfide',
     '1-nonanethiol',
     'naphthalene',
     'azulene',
     'butylbenzene',
     'm-diethylbenzene',
     'o-diethylbenzene',
     'p-diethylbenzene',
     '1,2,3,4-tetramethylbenzene',
     '1,2,3,5-tetramethylbenzene',
     '1,2,4,5-tetramethylbenzene',
     '1-decyne',
     'decahydronaphthalene,cis',
     'decahydronaphthalene,trans',
     '1-decene',
     '1-cyclopentylpentane',
     'butylcyclohexane',
     'decanal',
     'decane',
     '2-methylnonane',
     '3-methylnonane',
     '4-methylnonane',
     '5-methylnonane',
     '3-ethyloctane',
     '4-ethyloctane',
     '2,2-dimethyloctane',
     '2,3-dimethyloctane',
     '2,4-dimethyloctane',
     '2,5-dimethyloctane',
     '2,6-dimethyloctane',
     '2,7-dimethyloctane',
     '3,3-dimethyloctane',
     '3,4-dimethyloctane',
     '3,5-dimethyloctane',
     '3,6-dimethyloctane',
     '4,4-dimethyloctane',
     '4,5-dimethyloctane',
     '4-propylheptane',
     '4-isopropylheptane',
     '3-ethyl-2-methylheptane',
     '4-ethyl-2-methylheptane',
     '5-ethyl-2-methylheptane',
     '3-ethyl-3-methylheptane',
     '4-ethyl-3-methylheptane',
     '3-ethyl-5-methylheptane',
     '3-ethyl-4-methylheptane',
     '4-ethyl-4-methylheptane',
     '2,2,3-trimethylheptane',
     '2,2,4-trimethylheptane',
     '2,2,5-trimethylheptane',
     '2,2,6-trimethylheptane',
     '2,3,3-trimethylheptane',
     '2,3,4-trimethylheptane',
     '2,3,5-trimethylheptane',
     '2,3,6-trimethylheptane',
     '2,4,4-trimethylheptane',
     '2,4,5-trimethylheptane',
     '2,4,6-trimethylheptane',
     '2,5,5-trimethylheptane',
     '3,3,4-trimethylheptane',
     '3,3,5-trimethylheptane',
     '3,4,4-trimethylheptane',
     '3,4,5-trimethylheptane',
     '3-isopropyl-2-methylhexane',
     '3,3-diethylhexane',
     '3,4-diethylhexane',
     '3-ethyl-2,2-dimethylhexane',
     '4-ethyl-2,2-dimethylhexane',
     '3-ethyl-2,3-dimethylhexane',
     '4-ethyl-2,3-dimethylhexane',
     '3-ethyl-2,4-dimethylhexane',
     '4-ethyl-2,4-dimethylhexane',
     '3-ethyl-2,5-dimethylhexane',
     '4-ethyl-3,3-dimethylhexane',
     '3-ethyl-3,4-dimethylhexane',
     '2,2,3,3-tetramethylhexane',
     '2,2,3,4-tetramethylhexane',
     '2,2,3,5-tetramethylhexane',
     '2,2,4,4-tetramethylhexane',
     '2,2,4,5-tetramethylhexane',
     '2,2,5,5-tetramethylhexane',
     '2,3,3,4-tetramethylhexane',
     '2,3,3,5-tetramethylhexane',
     '2,3,4,4-tetramethylhexane',
     '2,3,4,5-tetramethylhexane',
     '3,3,4,4-tetramethylhexane',
     '24dimethyl3isopropylpentane',
     '33-diethyl-2-methylpentane',
     '3ethyl-223trimethylpentane',
     '3ethyl-224trimethylpentane',
     '3ethyl-234trimethylpentane',
     '22334-pentamethylpentane',
     '22344-pentamethylpentane',
     'decyl-alcohol',
     'butyl-hexyl-sulfide',
     'ethyl-octyl-sulfide',
     'heptyl-propyl-sulfide',
     'methyl-nonyl-sulfide',
     'pentyl-sulfide',
     '1-decanethiol',
     'pentyl-disulfide',
     '1-methylnaphthalene',
     '2-methylnaphthalene',
     'pentylbenzene',
     'pentamethylbenzene',
     '1-undecyne',
     '1-undecene',
     '1-cyclopentylhexane',
     'pentylcyclohexane',
     'undecane',
     'undecyl-alcohol',
     'butyl-heptyl-sulfide',
     'decyl-methyl-sulfide',
     'ethyl-nonyl-sulfide',
     'octyl-propyl-sulfide',
     '1-undecanethiol',
     'biphenyl',
     '1-ethylnaphthalene',
     '2-ethylnaphthalene',
     '1,2-dimethylnaphthalene',
     '1,3-dimethylnaphthalene',
     '1,4-dimethylnaphthalene',
     '1,5-dimethylnaphthalene',
     '1,6-dimethylnaphthalene',
     '1,7-dimethylnaphthalene',
     '2,3-dimethylnaphthalene',
     '2,6-dimethylnaphthalene',
     '2,7-dimethylnaphthalene',
     'hexylbenzene',
     '1,2,3-triethylbenzene',
     '1,2,4-triethylbenzene',
     '1,3,5-triethylbenzene',
     'hexamethylbenzene',
     '1-dodecyne',
     '1-dodecene',
     '1-cyclopentylheptane',
     '1-cyclohexylhexane',
     'dodecane',
     'dodecyl-alcohol',
     'butyl-octyl-sulfide',
     'decyl-ethyl-sulfide',
     'hexyl-sulfide',
     'methyl-undecyl-sulfide',
     'nonyl-propyl-sulfide',
     '1-dodecanethiol',
     'hexyl-disulfide',
     '1-propylnaphthalene',
     '2-propylnaphthalene',
     '2ethyl-3-methylnaphthalene',
     '2ethyl-6-methylnaphthalene',
     '2ethyl-7-methylnaphthalene',
     '1-phenylheptane',
     '1-tridecyne',
     '1-tridecene',
     '1-cyclopentyloctane',
     '1-cyclohexylheptane',
     'tridecane',
     '1-tridecanol',
     'butyl-nonyl-sulfide',
     'decyl-propyl-sulfide',
     'dodecyl-methyl-sulfide',
     'ethyl-undecyl-sulfide',
     '1-tridecanethiol',
     '1-butylnaphthalene',
     '2-butylnaphthalene',
     '1-phenyloctane',
     '1,2,3,4-tetraethylbenzene',
     '1,2,3,5-tetraethylbenzene',
     '1,2,4,5-tetraethylbenzene',
     '1-tetradecyne',
     '1-tetradecene',
     '1-cyclopentylnonane',
     '1-cyclohexyloctane',
     'tetradecane',
     '1-tetradecanol',
     'butyl-decyl-sulfide',
     'dodecyl-ethyl-sulfide',
     'heptyl-sulfide',
     'methyl-tridecyl-sulfide',
     'propyl-undecyl-sulfide',
     '1-tetradecanethiol',
     'heptyl-disulfide',
     '1-pentylnaphthalene',
     '2-pentylnaphthalene',
     '1-phenylnonane',
     '1-pentadecyne',
     '1-pentadecene',
     '1-cyclopentyldecane',
     '1-cyclohexylnonane',
     'pentadecane',
     '1-pentadecanol',
     'butyl-undecyl-sulfide',
     'dodecyl-propyl-sulfide',
     'ethyl-tridecyl-sulfide',
     'methyl-tetradecyl-sulfide',
     '1-pentadecanethiol',
     '1-phenyldecane',
     'pentaethylbenzene',
     '1-hexadecyne',
     '1-hexadecene',
     '1-cyclopentylundecane',
     '1-cyclohexyldecane',
     'hexadecane',
     '1-hexadecanol',
     'butyl-dodecyl-sulfide',
     'ethyl-tetradecyl-sulfide',
     'methyl-pentadecyl-sulfide',
     'octyl-sulfide',
     'propyl-tridecyl-sulfide',
     '1-hexadecanethiol',
     'octyl-disulfide',
     '1-phenylundecane',
     '1-heptadecyne',
     '1-heptadecene',
     '1-cyclopentyldodecane',
     '1-cyclohexylundecane',
     'heptadecane',
     '1-heptadecanol',
     'butyl-tridecyl-sulfide',
     'ethyl-pentadecyl-sulfide',
     'hexadecyl-methyl-sulfide',
     'propyl-tetradecyl-sulfide',
     '1-heptadecanethiol',
     '1-phenyldodecane',
     'hexaethylbenzene',
     '1-octadecyne',
     '1-octadecene',
     '1-cycopentyltridecane',
     '1-cyclohexyldodecane',
     'octadecane',
     '1-octadecanol',
     'butyl-tetradecyl-sulfide',
     'ethyl-hexadecyl-sulfide',
     'heptadecyl-methyl-sulfide',
     'nonyl-sulfide',
     'pentadecyl-propyl-sulfide',
     '1-octadecanethiol',
     'nonyl-disulfide',
     '1-phenyltridecane',
     '1-nonadecyne',
     '1-nonadecene',
     '1-cyclopentyltetradecane',
     '1-cyclohexyltridecane',
     'nonadecane',
     '1-nonadecanol',
     'butyl-pentadecyl-sulfide',
     'ethyl-heptadecyl-sulfide',
     'hexadecyl-propyl-sulfide',
     'methyl-octadecyl-sulfide',
     '1-nonadecanethiol',
     '1-phenyltetradecane',
     '1-eicosyne',
     '1-eicosene',
     '1-cyclopentylpentadecane',
     '1-cyclohexyltetradecane',
     'eicosane',
     '1-eicosanol',
     'butyl-hexadecyl-sulfide',
     'decyl-sulfide',
     'ethyl-octadecyl-sulfide',
     'heptadecyl-propyl-sulfide',
     'methyl-nonadecyl-sulfide',
     '1-eicosanethiol',
     'decyl-disulfide',
     '1-phenylpentadecane',
     '1-cyclopentylhexadecane',
     '1-cyclohexylpentadecane',
     '1-phenylhexadecane',
     '1-cyclohexylhexadecane']
  end

  def self.tank_type
    ['Atmospheric Storage', 'Low Pressure Storage', 'High Pressure Storage']
  end

  def self.design_code
    ['ASME I',
     'ASME VIII',
     'ANSI B31.3',
     'API 620',
     'API 650']
  end

  def self.stamped
    ['Yes', 'No']
  end

  def self.vessel_orientation
    ["Horizontal", "Vertical"]
  end

  def self.vessel_type
    ["Vertical Separator",
     "Horizontal Separator",
     "Decanter",
     "Settler",
     "Filter",
     "Reactor"]
  end

  def self.microns
    ["Nominal", "Absolute"]
  end

  def self.no_of_nozzles
    [1, 2, 3]
  end

  def self.inlet_device
    ["No Inlet Device",
     "Deflector Baffle",
     "Slotted Tee Distributor",
     "Half Open Pipe",
     "90&deg; Elbow",
     "Tangential Inlet With Annular Ring",
     "Schoepentoeter",
     "Sloped Diverter",
     "Submerged Pipe"]
  end

  def self.nozzle_size
    [{:name => "&frac14;", :value => 0.25},
     {:name => "&frac12;", :value => 0.5},
     {:name => "&frac34;", :value => 0.75},
     {:name => "1", :value => 1.0},
     {:name => "1&frac14;", :value => 1.25},
     {:name => "1&frac12;", :value => 1.5},
     {:name => "2", :value => 2.0},
     {:name => "2&frac12;", :value => 2.5},
     {:name => "3", :value => 3.0},
     {:name => "3&frac12;", :value => 3.5},
     {:name => "4", :value => 4.0},
     {:name => "5", :value => 5.0},
     {:name => "6", :value => 6.0},
     {:name => "8", :value => 8.0},
     {:name => "10", :value => 10.0},
     {:name => "12", :value => 12.0},
     {:name => "14", :value => 14.0},
     {:name => "16", :value => 16.0},
     {:name => "18", :value => 18.0},
     {:name => "20", :value => 20.0},
     {:name => "22", :value => 22.0},
     {:name => "24", :value => 24.0},
     {:name => "26", :value => 26.0},
     {:name => "28", :value => 28.0},
     {:name => "30", :value => 30.0},
     {:name => "32", :value => 32.0},
     {:name => "34", :value => 34.0},
     {:name => "36", :value => 36.0},
     {:name => "48", :value => 48.0},
     {:name => "56", :value => 56.0},
     {:name => "72", :value => 72.0}
    ]
  end

  def self.foaming_service
    ["Absorber (over 0&deg;F)",
     "Absorber (below 0&deg;F)",
     "Amine Contactor",
     "Vacuum Towers",
     "Amine Still (Amine Regenerator",
     "H2S Stripper",
     "Furfural Fractionator",
     "Top Section of Absorber Type Demethanizer",
     "Glycol Contactors",
     "Glycol Stills",
     "CO2 Absorber",
     "CO2 Regenerator",
     "Caustic Wash",
     "Caustic Regenerator",
     "Foul Water",
     "Sour Water Stripper",
     "Alcohol Synthesis Absorber",
     "Hot Carbonate Contactor",
     "Hot Carbonate Regenerator",
     "Oil Reclaimer",
     "High Pressure Fractionator with > 1.8 lb/ft3 density",
     "Others"
    ]
  end

  def self.type_of_trays
    ["Bubble", "Valve", "Sieve"]
  end

  def self.tray_foaming_tendency
    ["None", "Moderate", "High", "Severe"]
  end

  def self.tube_od
    [
      {:name => "&frac14;", :value => 0.25},
      {:name => "&frac38;", :value => 0.375},
      {:name => "&frac12;", :value => 0.5},
      {:name => "&frac58;", :value => 0.625},
      {:name => "&frac34;", :value => 0.75},
      {:name => "1", :value => 1.0},
      {:name => "1&frac14", :value => 1.25},
      {:name => "1&frac12", :value => 1.5},
      {:name => "2", :value => 2}
    ]
  end

  def self.tube_thickness
    %w(7 8 10 11 12 13 14 15 16 17 18 19 20 22 24 26 27)
  end

  def self.sizings
    %w(line_sizing vessel_sizing pump_sizing compressor_sizing_tag control_valve_sizing flow_element_sizing storage_tank_sizing column_sizing heat_exchanger_sizing relief_device_sizing electric_motor steam_turbine hydraulic_turbine turbo_expander)
  end

  def self.bx_range_1
    ['Annular', 'Wave', 'Stratified']
  end

  def self.bx_range_2
    ['Dispersed/Spray/Mist', 'Annular', 'Wave', 'Stratified']
  end

  def self.bx_range_3
    ['Dispersed/Spray/Mist', 'Annular', 'Slug', 'Wave', 'Stratified']
  end

  def self.bx_range_4
    ['Dispersed/Spray/Mist', 'Annular', 'Slug', 'Stratified']
  end

  def self.bx_range_5
    ['Dispersed/Spray/Mist', 'Annular', 'Slug', 'Plug', 'Stratified']
  end

  def self.bx_range_6
    ['Bubble/Froth', 'Slug', 'Plug', 'Stratified']
  end

  def self.bx_range_7
    ['Bubble/Froth', 'Slug', 'Plug']
  end

end
