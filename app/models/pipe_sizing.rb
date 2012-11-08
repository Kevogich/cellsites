class PipeSizing < ActiveRecord::Base
	belongs_to :line_sizing

	validates_presence_of :length, :elev, :if => Proc.new {|p| p.fitting_id == 1 }
	validates_presence_of :ds_cv, :if => Proc.new {|p| [38,39,40,41].include?(p.fitting_id) } 

	#this fitting is only used for line sizing
	def self.fitting
		[
			{:id => "1", :value => "Pipe"},
			{:id => "2", :value => "Valve - Gate (Full Bore)"},
			{:id => "3", :value => "Valve - Ball (Full Bore)"},
			{:id => "4", :value => "Valve - Globe (Full Bore)"},
			{:id => "5", :value => "Valve - Butterfly Valve (Full Bore)"},
			{:id => "6", :value => "Valve - Angle (45&deg;, Full Bore)"},
			{:id => "7", :value => "Valve - Angle (90&deg;, Full Bore)"},
			{:id => "8", :value => "Valve - Swing Check"},
			{:id => "9", :value => "Valve - Lift Check"},
			{:id => "10", :value => "Valve - Plug (Branch Flow)"},
			{:id => "11", :value => "Valve - Plug (Straight Through)"},
			{:id => "12", :value => "Valve - Plug (3 way Flow Through)"},
			{:id => "13", :value => "Valve - Diaphragm (Dam Type)"},
			{:id => "14", :value => "Tee - Through Branch (Threaded, r/D = 1)"},
			{:id => "15", :value => "Tee - Through Branch (Threaded, r/D = 1.5)"},
			{:id => "16", :value => "Tee - Through Branch (Flanged)"},
			{:id => "17", :value => "Tee - Through Branch (Stub-In Branch)"},
			{:id => "18", :value => "Tee - Run Through (Threaded)"},
			{:id => "19", :value => "Tee - Run Through (Flanged)"},
			{:id => "20", :value => "Tee - Run Through (Stub-In Branch)"},
			{:id => "21", :value => "Elbow - 90&deg; (Threaded, Standard)"},
			{:id => "22", :value => "Elbow - 90&deg; (Threaded, Long Radius)"},
			{:id => "23", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 1)"},
			{:id => "24", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 2)"},
			{:id => "25", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 4)"},
			{:id => "26", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 6)"},
			{:id => "27", :value => "Elbow - 90&deg; (Mitered, 1 Weld, 90&deg;)"},
			{:id => "28", :value => "Elbow - 90&deg; (Mitered, 2 Welds, 45&deg;)"},
			{:id => "29", :value => "Elbow - 90&deg; (Mitered, 3 Welds, 30&deg;)"},
			{:id => "30", :value => "Elbow - 45&deg; (Threaded, Standard)"},
			{:id => "31", :value => "Elbow - 45&deg; (Long Radius)"},
			{:id => "32", :value => "Elbow - 45&deg; (Mitered, 1 Weld, 45&deg;)"},
			{:id => "33", :value => "Elbow - 45&deg; (Mitered, 2 Welds, 22.5&deg;)"},
			{:id => "34", :value => "Elbow - 180&deg; (Threaded, Close Return Bend)"},
			{:id => "35", :value => "Elbow - 180&deg; (Flanged)"},
			{:id => "36", :value => "Elbow - 180&deg; (All)"},
			{:id => "38", :value => "Contraction"},
			{:id => "39", :value => "Expansion"},
			{:id => "40", :value => "Sudden Expansion"},
			{:id => "41", :value => "Sudden Contraction"},
			{:id => "42", :value => "Entrance - Inward Projecting (Borda)"},
			{:id => "43", :value => "Entrance - Flush (Sharply Edged, r/D = 0)"},
			{:id => "44", :value => "Entrance - Flush (Rounded, r/D = 0.02)"},
			{:id => "45", :value => "Entrance - Flush (Rounded, r/D = 0.04)"},
			{:id => "46", :value => "Entrance - Flush (Rounded, r/D = 0.06)"},
			{:id => "47", :value => "Entrance - Flush (Rounded, r/D = 0.10)"},
			{:id => "48", :value => "Entrance - Flush (Rounded, r/D > 0.15)"},
			{:id => "49", :value => "Exit - Pipe"},
			{:id => "50", :value => "Rupture Disk"},
			{:id => "51", :value => "User Entered"}
		]
	end

	def self.fitting1
	[	
		{:id => "1", :value => "Pipe"},
		{:id => "2", :value => "Valve - Gate (Full Bore)"},
		{:id => "3", :value => "Valve - Ball (Full Bore)"},
		{:id => "4", :value => "Valve - Globe (Full Bore)"},
		{:id => "5", :value => "Valve - Buttterfly Valve (Full Bore)"},
		{:id => "6", :value => "Valve - Angle (45&deg;, Full Bore)"},
		{:id => "7", :value => "Valve - Angle (90&deg;, Full Bore)"},
		{:id => "8", :value => "Valve - Swing Check"},
		{:id => "9", :value => "Valve - Lift Check"},
		{:id => "10", :value => "Valve - Plug (Branch Flow)"},
		{:id => "11", :value => "Valve - Plug (Straight Through)"},
		{:id => "12", :value => "Valve - Plug (3 way Flow Through)"},
		{:id => "13", :value => "Valve - Diaphragm (Dam Type)"},
		{:id => "14", :value => "Tee - Through Branch (Threaded, r/D = 1)"},
		{:id => "15", :value => "Tee - Through Branch (Threaded, r/D = 1.5)"},
		{:id => "16", :value => "Tee - Through Branch (Flanged)"},
		{:id => "17", :value => "Tee - Through Branch (Stub-In Branch)"},
		{:id => "18", :value => "Tee - Run Through (Threaded)"},
		{:id => "19", :value => "Tee - Run Through (Flanged)"},
		{:id => "20", :value => "Tee - Run Through (Stub-In Branch)"},
		{:id => "21", :value => "Elbow - 90&deg; (Threaded, Standard)"},
		{:id => "22", :value => "Elbow - 90&deg; (Threaded, Long Radius)"},
		{:id => "23", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 1)"},
		{:id => "24", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 2)"},
		{:id => "25", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 4)"},
		{:id => "26", :value => "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 6)"},
		{:id => "27", :value => "Elbow - 90&deg; (Mitered, 1 Weld, 90&deg;)"},
		{:id => "28", :value => "Elbow - 90&deg; (Mitered, 2 Welds, 45&deg;)"},
		{:id => "29", :value => "Elbow - 90&deg; (Mitered, 3 Welds, 30&deg;)"},
		{:id => "30", :value => "Elbow - 45&deg; (Threaded, Standard)"},
		{:id => "31", :value => "Elbow - 45&deg; (Long Radius)"},
		{:id => "32", :value => "Elbow - 45&deg; (Mitered, 1 Weld, 45&deg;)"},
		{:id => "33", :value => "Elbow - 45&deg; (Mitered, 2 Welds, 22.5&deg;)"},
		{:id => "34", :value => "Elbow - 180&deg; (Threaded, Close Return Bend)"},
		{:id => "35", :value => "Elbow - 180&deg; (Flanged)"},
		{:id => "36", :value => "Elbow - 180&deg; (All)"},
		{:id => "37", :value => "Contraction"},
		{:id => "38", :value => "Expansion"},
		{:id => "39", :value => "Sudden Expansion"},
		{:id => "40", :value => "Sudden Contraction"},
		{:id => "41", :value => "Entrance - Inward Projecting (Borda)"},
		{:id => "42", :value => "Entrance - Flush (Sharply Edged, r/D = 0)"},
		{:id => "43", :value => "Entrance - Flush (Rounded, r/D = 0.02)"},
		{:id => "44", :value => "Entrance - Flush (Rounded, r/D = 0.04)"},
		{:id => "45", :value => "Entrance - Flush (Rounded, r/D = 0.06)"},
		{:id => "46", :value => "Entrance - Flush (Rounded, r/D = 0.10)"},
		{:id => "47", :value => "Entrance - Flush (Rounded, r/D > 0.15)"},
		{:id => "48", :value => "Exit - Pipe"},
		{:id => "49", :value => "Rupture Disk"},
		{:id => "50", :value => "User Entered"},
		{:id => "51", :value => "Orifice"},
		{:id => "52", :value => "Control Valve"},
		{:id => "53", :value => "Flow Element - Venturi (Machined Inlet)"},
		{:id => "54", :value => "Flow Element - Venturi (Rough Cast Inlet)"},
		{:id => "55", :value => "Flow Element - Venturi (Rough Welded Sheet - Iron Inlet)"},
		{:id => "56", :value => "Flow Element - Universal Venturi Tube"},
		{:id => "57", :value => "Flow Element - Lo-Loss Tube"},
		{:id => "58", :value => "Flow Element - Nozzle (ASME Long Radius)"},
		{:id => "59", :value => "Flow Element - Nozzle (ISA)"},
		{:id => "60", :value => "Flow Element - Nozzle (Venturi Nozzle - ISA Inlet)"},
		{:id => "61", :value => "Flow Element - Orifice Plate (Corner Tap)"},
		{:id => "62", :value => "Flow Element - Orifice Plate (Flange Tap with D > 2.3 inches)"},
		{:id => "63", :value => "Flow Element - Orifice Plate (Flange Tap with D >= 2 and D <= 2.3 inches)"},
		{:id => "64", :value => "Flow Element - Orifice Plate (Flange Tap with D > 58.4 millimeters)"},
		{:id => "65", :value => "Flow Element - Orifice Plate (Flange Tap with D >=50.8 and D <= 58.4 millimeters)"},
		{:id => "66", :value => "Flow Element - Orifice Plate (D and D/2 Taps)"},
		{:id => "67", :value => "Flow Element - Orifice Plate (2D and 8D Taps or Pipe Taps)"},
		{:id => "68", :value => "Equipment"},
		{:id => "69", :value => "Line Segment"},
		{:id => "70", :value => "Equivalent Length"},
		{:id => "71", :value => "Change Properties To Stream"}
	]
	end

	def self.get_fitting_tag(id)
		fitting = {}   
		self.fitting.each do |i|
			break fitting = i if id == i[:id]
		end    
		return fitting
	end

	def self.get_fitting_tag1(id)
		fitting = {}   
		self.fitting1.each do |i|
			break fitting = i if id == i[:id]
		end    
		return fitting
	end

	def self.pipe_sizes(unit_type=nil)
		if unit_type == 'mm'
			[
				{:id => "1", :name => "6", :value => 0.125},
				{:id => "2", :name => "8", :value => 0.25},
				{:id => "3", :name => "10", :value => 0.375},
				{:id => "4", :name => "15", :value => 0.5},
				{:id => "5", :name => "20", :value => 0.75},
				{:id => "6", :name => "25", :value => 1.0},
				{:id => "7", :name => "32", :value => 1.25},
				{:id => "8", :name => "40", :value => 1.5},
				{:id => "10", :name => "50", :value => 2.0},
				{:id => "11", :name => "65", :value => 2.5},
				{:id => "12", :name => "80", :value => 3.0},
				{:id => "13", :name => "90", :value => 3.5},
				{:id => "14", :name => "100", :value => 4.0},
				{:id => "15", :name => "125", :value => 5.0},
				{:id => "16", :name => "150", :value => 6.0},
				{:id => "17", :name => "200", :value => 8.0},
				{:id => "18", :name => "250", :value => 10.0},
				{:id => "19", :name => "300", :value => 12.0},
				{:id => "20", :name => "350", :value => 14.0},
				{:id => "21", :name => "400", :value => 16.0},
				{:id => "22", :name => "450", :value => 18.0},
				{:id => "23", :name => "500", :value => 20.0},
				{:id => "24", :name => "550", :value => 22.0},
				{:id => "25", :name => "600", :value => 24.0},
				{:id => "26", :name => "650", :value => 26.0},
				{:id => "27", :name => "700", :value => 28.0},
				{:id => "28", :name => "750", :value => 30.0},
				{:id => "29", :name => "800", :value => 32.0},
				{:id => "30", :name => "850", :value => 34.0},
				{:id => "31", :name => "900", :value => 36.0},
				{:id => "32", :name => "1000", :value => 48.0},
				{:id => "33", :name => "1050", :value => 56.0},
				{:id => "34", :name => "1100", :value => 72.0}
			]
		else 
			[
				{:id => "1", :name => "&#8539;", :value => 0.125},
				{:id => "2", :name => "&frac14;", :value => 0.25},
				{:id => "3", :name => "&#8540;", :value => 0.375},
				{:id => "4", :name => "&frac12;", :value => 0.5},
				{:id => "5", :name => "&frac34;", :value => 0.75},
				{:id => "6", :name => "1", :value => 1.0},
				{:id => "7", :name => "1&frac14;", :value => 1.25},
				{:id => "8", :name => "1&frac12;", :value => 1.5},
				{:id => "10", :name => "2", :value => 2.0},
				{:id => "11", :name => "2&frac12;", :value => 2.5},
				{:id => "12", :name => "3", :value => 3.0},
				{:id => "13", :name => "3&frac12;", :value => 3.5},
				{:id => "14", :name => "4", :value => 4.0},
				{:id => "15", :name => "5", :value => 5.0},
				{:id => "16", :name => "6", :value => 6.0},
				{:id => "17", :name => "8", :value => 8.0},
				{:id => "18", :name => "10", :value => 10.0},
				{:id => "19", :name => "12", :value => 12.0},
				{:id => "20", :name => "14", :value => 14.0},
				{:id => "21", :name => "16", :value => 16.0},
				{:id => "22", :name => "18", :value => 18.0},
				{:id => "23", :name => "20", :value => 20.0},
				{:id => "24", :name => "22", :value => 22.0},
				{:id => "25", :name => "24", :value => 24.0},
				{:id => "26", :name => "26", :value => 26.0},
				{:id => "27", :name => "28", :value => 28.0},
				{:id => "28", :name => "30", :value => 30.0},
				{:id => "29", :name => "32", :value => 32.0},
				{:id => "30", :name => "34", :value => 34.0},
				{:id => "31", :name => "36", :value => 36.0},
				{:id => "32", :name => "48", :value => 48.0},
				{:id => "33", :name => "56", :value => 56.0},
				{:id => "34", :name => "72", :value => 72.0}
			]
		end
	end


	def self.pipe_size_to_fraction
		v = {}
		self.pipe_sizes.each do |p|
			v[p[:value]] = p[:name]
		end
		return v
	end

	def self.nominal_pipe_diameter
		{
			0.125 => 6,
			0.25  => 8,
			0.375 => 10,
			0.5   => 15,
			0.75  => 20,
			1.0   => 25,
			1.25  => 32,
			1.5   => 40,
			2.0   => 50,
			2.5  => 65,
			3.0   => 80,
			3.5   => 90,
			4.0   => 100,
			5.0   => 125,
			6.0   => 150,
			8.0   => 200,
			10.0  => 250,
			12.0  => 300,
			14.0  => 350,
			16.0  => 400,
			18.0  => 450,
			20.0  => 500,
			22.0  => 550,
			24.0  => 600,
			26.0  => 650,
			28.0  => 700,
			30.0  => 750,
			32.0  => 800,
			34.0  => 850,
			36.0  => 900,
			48.0  => 1200,
			56.0  => 1400,
			72.0  => 1800
		}
	end

	def self.pipe_size_mapping
	end

	def self.pipe_size_to_pipe_od(pipe_size,unit_type)
		pipe_id = 0.0

		if unit_type == 'mm'
			if pipe_size == 6 
				pipe_od = 0.405
			elsif pipe_size == 8 
				pipe_od = 0.54
			elsif pipe_size == 10 
				pipe_od = 0.675
			elsif pipe_size == 15 
				pipe_od = 0.84
			elsif pipe_size == 20 
				pipe_od = 1.05
			elsif pipe_size == 25 
				pipe_od = 1.315
			elsif pipe_size == 32 
				pipe_od = 1.66
			elsif pipe_size == 40 
				pipe_od = 1.9
			elsif pipe_size == 50 
				pipe_od = 2.375
			elsif pipe_size == 65 
				pipe_od = 2.875
			elsif pipe_size == 80 
				pipe_od = 3.5
			elsif pipe_size == 90 
				pipe_od = 4
			elsif pipe_size == 100 
				pipe_od = 4.5
			elsif pipe_size == 125 
				pipe_od = 5.563
			elsif pipe_size == 150 
				pipe_od = 6.625
			elsif pipe_size == 200 
				pipe_od = 8.625
			elsif pipe_size == 250 
				pipe_od = 10.75
			elsif pipe_size == 300 
				pipe_od = 12.75
			elsif pipe_size == 350 
				pipe_od = 14
			elsif pipe_size == 400 
				pipe_od = 16
			elsif pipe_size == 450 
				pipe_od = 18
			elsif pipe_size == 500 
				pipe_od = 20
			elsif pipe_size == 550 
				pipe_od = 22
			elsif pipe_size == 600 
				pipe_od = 24
			elsif pipe_size == 650 
				pipe_od = 26
			elsif pipe_size == 700 
				pipe_od = 28
			elsif pipe_size == 750 
				pipe_od = 30
			elsif pipe_size == 800 
				pipe_od = 32
			elsif pipe_size == 850 
				pipe_od = 34
			elsif pipe_size == 900 
				pipe_od = 36
			elsif pipe_size == 1200 
				pipe_od = 48
			elsif pipe_size == 1400 
				pipe_od = 56
			elsif pipe_size == 1800
				pipe_od = 72
			end

		elsif unit_type == 'in'
			if pipe_size == 0.125
				pipe_od = 0.405
			elsif pipe_size == 0.25 
				pipe_od = 0.54
			elsif pipe_size == 0.275 
				pipe_od = 0.675
			elsif pipe_size == 0.5 
				pipe_od = 0.84
			elsif pipe_size == 0.75
				pipe_od = 1.05
			elsif pipe_size == 1 
				pipe_od = 1.315
			elsif pipe_size == 1.25 
				pipe_od = 1.66
			elsif pipe_size == 1.5 
				pipe_od = 1.9
			elsif pipe_size == 2 
				pipe_od = 2.375
			elsif pipe_size == 2.5 
				pipe_od = 2.875
			elsif pipe_size == 3 
				pipe_od = 3.5
			elsif pipe_size == 3.5 
				pipe_od = 4
			elsif pipe_size == 4 
				pipe_od = 4.5
			elsif pipe_size == 5 
				pipe_od = 5.563
			elsif pipe_size == 6 
				pipe_od = 6.625
			elsif pipe_size == 8 
				pipe_od = 8.625
			elsif pipe_size == 10 
				pipe_od = 10.75
			elsif pipe_size == 12 
				pipe_od = 12.75
			elsif pipe_size == 14 
				pipe_od = 14
			elsif pipe_size == 16 
				pipe_od = 16
			elsif pipe_size == 18 
				pipe_od = 18
			elsif pipe_size == 20 
				pipe_od = 20
			elsif pipe_size == 22 
				pipe_od = 22
			elsif pipe_size == 24 
				pipe_od = 24
			elsif pipe_size == 26 
				pipe_od = 26
			elsif pipe_size == 28 
				pipe_od = 28
			elsif pipe_size == 30 
				pipe_od = 30
			elsif pipe_size == 32 
				pipe_od = 32
			elsif pipe_size == 34 
				pipe_od = 34
			elsif pipe_size == 36 
				pipe_od = 36
			elsif pipe_size == 48 
				pipe_od = 48
			elsif pipe_size == 56 
				pipe_od = 56
			elsif pipe_size == 72 
				pipe_od = 72
			end
		end

		return pipe_od
	end

	def self.pipe_size_schedules
		{
			"" => [],
			"0.125" => ["Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS"],
			"0.25" => ["Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS"],
			"0.375" => ["Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS"],
			"0.5"  => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"0.75" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"1.0" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"1.25" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"1.5"  => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"2.0" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"2.5"  => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"3.0" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 160", "Sch. XX"],
			"3.5" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. XX"],
			"4.0" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 120", "Sch. 160", "Sch. XX"],
			"5.0" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 120", "Sch. 160", "Sch. XX"],
			"6.0" => ["Sch. 5S", "Sch. 10S", "Sch. 40S", "Sch. 40ST", "Sch. 80S", "Sch. 80XS", "Sch. 120", "Sch. 160", "Sch. XX"],
			"8.0" => ["Sch. 5S", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40S", "Sch. 40ST", "Sch. 60", "Sch. 80S", "Sch. 80XS", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160","Sch. XX"],
			"10.0" => ["Sch. 5S", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40S", "Sch. 40ST", "Sch. 60", "Sch. 60XS", "Sch. 80", "Sch. 80S", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. XX"],
			"12.0" => ["Sch. 5S", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40", "Sch. 40S", "Sch. 60", "Sch. 80", "Sch. 80S", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS", "Sch. XX"],
			"14.0" => ["Sch. 5S", "Sch. 10", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS"],
			"16.0" => ["Sch. 5S", "Sch. 10", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS"],
			"18.0" => ["Sch. 5S", "Sch. 10", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS"],
			"20.0" => ["Sch. 5S", "Sch. 10", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS"],
			"22.0" => ["Sch. 5S","Sch. 10", "Sch. 10S","Sch. 20", "Sch. 30", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS"],
			"24.0" => ["Sch. 5S", "Sch. 10", "Sch. 10S", "Sch. 20", "Sch. 30", "Sch. 40", "Sch. 60", "Sch. 80", "Sch. 100", "Sch. 120", "Sch. 140", "Sch. 160", "Sch. ST", "Sch. XS"],
			"26.0" => ["Sch. 10", "Sch. 20", "Sch. ST", "Sch. XS"],
			"28.0" => ["Sch. 10","Sch. 20", "Sch. 30", "Sch. ST", "Sch. XS"],
			"30.0" => ["Sch. 5S", "Sch. 10", "Sch. 10S", "Sch. 20", "Sch. 30","Sch. ST", "Sch. XS"],
			"32.0" => ["Sch. 10", "Sch. 20", "Sch. 30", "Sch. 40","Sch. ST", "Sch. XS"],
			"34.0" => ["Sch. 10", "Sch. 20", "Sch. 30", "Sch. 40","Sch. ST", "Sch. XS"],
			"36.0" => ["Sch. 10", "Sch. 20", "Sch. 30", "Sch. 40","Sch. ST", "Sch. XS"],
			"48.0" => ["Sch. ST", "Sch. XS"],
			"56.0" => ["Sch. ST", "Sch. XS"],
			"72.0" => ["Sch. ST", "Sch. XS"]
		}
	end

	def self.pipe_size_pipe_od
		{
			"" => 0,
			"0.125" => 0.405,
			"0.25" => 0.54,
			"0.375" => 0.675,
			"0.5" => 0.84,
			"0.75" => 1.05,
			"1.0" => 1.315,
			"1.25" => 1.66,
			"1.5" => 1.9,
			"1.75" => 0,
			"2.0" => 2.375,
			"2.5" => 2.875,
			"3.0" => 3.5,
			"3.5" => 4,
			"4.0" => 4.5,
			"5.0" => 5.563,
			"6.0" => 6.625,
			"8.0" => 8.625,
			"10.0" => 10.75,
			"12.0" => 12.75,
			"14.0" => 14,
			"16.0" => 16,
			"18.0" => 18,
			"20.0" => 20,
			"22.0" => 22,
			"24.0" => 24,
			"26.0" => 26,
			"28.0" => 28,
			"30.0" => 30,
			"32.0" => 32,
			"34.0" => 34,
			"36.0" => 36,
			"48.0" => 48,
			"56.0" => 56,
			"72.0" => 72
		}
	end

	def self.pipe_size_wall_thinkness
		{
			"0.125" => {"Sch. 10S" => "0.049", "Sch. 40S" => "0.068", "Sch. 40ST"=>"0.068", "Sch. 80S" => "0.095", "Sch. 80XS" => "0.095"},
			"0.25"  => {"Sch. 10S" => "0.065", "Sch. 40S" => "0.088", "Sch. 40ST" => "0.088", "Sch. 80S" => "0.119", "Sch. 80XS" => "0.119"},
			"0.375" => {"Sch. 10S" => "0.065", "Sch. 40S" =>"0.091", "Sch. 40ST" => "0.091", "Sch. 80S" => "0.126", "Sch. 80XS" =>"0.126"},
			"0.5"  => {"Sch. 5S" => "0.065", "Sch. 10S" => "0.083", "Sch. 40S" =>"0.109", "Sch. 40ST" =>"0.109", "Sch. 80S" =>"0.147", "Sch. 80XS" =>"0.147", "Sch. 160" =>"0.188", "Sch. XX" =>"0.294"},
			"0.75" => {"Sch. 5S" =>"0.065", "Sch. 10S" =>"0.083", "Sch. 40S" =>"0.113", "Sch. 40ST" =>"0.113", "Sch. 80S" => "0.154", "Sch. 80XS" =>"0.154", "Sch. 160" =>"0.219", "Sch. XX" =>"0.308"},
			"1.0" => {"Sch. 5S" =>"0.065", "Sch. 10S" =>"0.109", "Sch. 40S" =>"0.133", "Sch. 40ST" =>"0.133", "Sch. 80S" =>"0.179", "Sch. 80XS" => "0.179", "Sch. 160" =>"0.25", "Sch. XX" =>"0.358"},
			"1.25" => {"Sch. 5S" =>"0.065", "Sch. 10S" =>"0.109", "Sch. 40S" =>"0.14", "Sch. 40ST" =>"0.14", "Sch. 80S" =>"0.191", "Sch. 80XS" =>"0.191", "Sch. 160" =>"0.25", "Sch. XX" =>"0.382"},
			"1.5"  => {"Sch. 5S" =>"0.065", "Sch. 10S" =>"0.109", "Sch. 40S" =>"0.145", "Sch. 40ST" =>"0.145", "Sch. 80S" =>"0.2", "Sch. 80XS" =>"0.2", "Sch. 160" =>"0.281", "Sch. XX" => "0.4"},
			"2.0" => {"Sch. 5S" =>"0.065", "Sch. 10S" =>"0.109", "Sch. 40S" =>"0.154", "Sch. 40ST" =>"0.154", "Sch. 80S" =>"0.218", "Sch. 80XS" =>"0.218", "Sch. 160" =>"0.218", "Sch. XX" => "0.436"},
			"2.5"  => {"Sch. 5S" =>"0.083", "Sch. 10S" =>"0.12", "Sch. 40S" =>"0.203", "Sch. 40ST" =>"0.203", "Sch. 80S" =>"0.276", "Sch. 80XS" =>"0.276", "Sch. 160" =>"0.375", "Sch. XX" =>"0.552"},
			"3.0" => {"Sch. 5S" =>"0.083", "Sch. 10S" =>"0.12", "Sch. 40S" =>"0.216", "Sch. 40ST" =>"0.216", "Sch. 80S" =>"0.3", "Sch. 80XS" =>"0.3", "Sch. 160" =>"0.438", "Sch. XX" =>"0.6"},
			"3.5" => {"Sch. 5S"=> "0.083", "Sch. 10S"=> "0.12", "Sch. 40S"=> "0.226", "Sch. 40ST"=> "0.226", "Sch. 80S"=> "0.318", "Sch. 80XS"=> "0.318","Sch. XX" =>"0.636"},
			"4.0" => {"Sch. 5S" => "0.083", "Sch. 10S" => "0.12", "Sch. 40S" => "0.237", "Sch. 40ST" => "0.237", "Sch. 80S" => "0.337", "Sch. 80XS" => "0.337", "Sch. 120" => "0.438", "Sch. 160" => "0.531", "Sch. XX" =>"0.674"},
			"5.0" => {"Sch. 5S" => "0.109", "Sch. 10S" => "0.134", "Sch. 40S" => "0.258", "Sch. 40ST" => "0.258", "Sch. 80S" => "0.375", "Sch. 80XS" => "0.375", "Sch. 120" => "0.5", "Sch. 160" => "0.625", "Sch. XX" =>"0.75"},
			"6.0" => {"Sch. 5S" => "0.109", "Sch. 10S" => "0.134", "Sch. 40S" => "0.28", "Sch. 40ST" => "0.28", "Sch. 80S" => "0.432", "Sch. 80XS" => "0.432", "Sch. 120" => "0.562", "Sch. 160" => "0.719", "Sch. XX" => "0.864"},
			"8.0" => {"Sch. 5S" => "0.109", "Sch. 10S" => "0.148", "Sch. 20" => "0.25", "Sch. 30" => "0.277", "Sch. 40S" => "0.322", "Sch. 40ST" => "0.322", "Sch. 60" => "0.406", "Sch. 80S" => "0.5", "Sch. 80XS" => "0.5", "Sch. 100" => "0.594", "Sch. 120" => "0.719", "Sch. 140" => "0.812", "Sch. 160" => "0.906", "Sch. XX" => "0.875"},
			"10.0" => {"Sch. 5S" => "0.134", "Sch. 10S" => "0.165", "Sch. 20" => "0.25", "Sch. 30" => "0.307", "Sch. 40S" => "0.365", "Sch. 40ST" => "0.365", "Sch. 60" => "0.500", "Sch. 60XS" => "0.5", "Sch. 80" => "0.594", "Sch. 80S" => "0.5", "Sch. 100" => "0.719", "Sch. 120" => "0.844", "Sch. 140" => "1", "Sch. 160" => "1.125", "Sch. XX" => "1"},
			"12.0" => {"Sch. 5S" => "0.156", "Sch. 10S" => "0.18", "Sch. 20" => "0.25", "Sch. 30" => "0.33", "Sch. 40" => "0.406", "Sch. 40S" => "0.375", "Sch. 60" => "0.562", "Sch. 80" => "0.688", "Sch. 80S" => "0.5", "Sch. 100" => "0.844", "Sch. 120" => "1", "Sch. 140" => "1.125", "Sch. 160" => "1.312", "Sch. ST" => "0.375", "Sch. XS" =>"0.5", "Sch. XX" => "1"},
			"14.0" => {"Sch. 5S" => "0.156", "Sch. 10" => "0.25", "Sch. 10S" => "0.188", "Sch. 20" => "0.312", "Sch. 30" => "0.375", "Sch. 40" => "0.438", "Sch. 60" => "0.594", "Sch. 80" => "0.75", "Sch. 100" => "0.938", "Sch. 120" => "1.094", "Sch. 140" => "1.25", "Sch. 160" => "1.406", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"16.0" => {"Sch. 5S" => "0.165", "Sch. 10" => "0.25", "Sch. 10S" => "0.188", "Sch. 20" => "0.312", "Sch. 30" => "0.375", "Sch. 40" => "0.5", "Sch. 60" => "0.656", "Sch. 80" => "0.844", "Sch. 100" => "1.031", "Sch. 120" => "1.219", "Sch. 140" => "1.438", "Sch. 160" => "1.594", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"18.0" => {"Sch. 5S" => "0.165", "Sch. 10" => "0.25", "Sch. 10S" => "0.188", "Sch. 20" => "0.312", "Sch. 30" => "0.375", "Sch. 40" => "0.562", "Sch. 60" => "0.75", "Sch. 80" => "0.938", "Sch. 100" => "1.156", "Sch. 120" => "1.375", "Sch. 140" => "1.562", "Sch. 160" => "1.781", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"20.0" => {"Sch. 5S" => "0.188", "Sch. 10" => "0.25", "Sch. 10S" => "0.218", "Sch. 20" => "0.375", "Sch. 30" => "0.5", "Sch. 40" => "0.594", "Sch. 60" => "0.812", "Sch. 80" => "1.031", "Sch. 100" => "1.281", "Sch. 120" => "1.5", "Sch. 140" => "1.75", "Sch. 160" => "1.969", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"22.0" => {"Sch. 5S" => "0.188", "Sch. 10" => "0.25", "Sch. 10S" => "0.218", "Sch. 20" => "0.375", "Sch. 30" => "0.5", "Sch. 60" => "0.875", "Sch. 80" => "1.125", "Sch. 100" => "1.375", "Sch. 120" => "1.625", "Sch. 140" => "1.875", "Sch. 160" => "2.125", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"24.0" => {"Sch. 5S" => "0.218", "Sch. 10" => "0.25", "Sch. 10S" => "0.25", "Sch. 20" => "0.375", "Sch. 30" => "0.562", "Sch. 40" => "0.688", "Sch. 60" => "0.969", "Sch. 80" => "1.219", "Sch. 100" => "1.531", "Sch. 120" => "1.812", "Sch. 140" => "2.062", "Sch. 160" => "2.344", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"26.0" => {"Sch. 10" => "0.312","Sch. 20" => "0.5", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"28.0" => {"Sch. 10" => "0.312","Sch. 20" => "0.5","Sch. 30" => "0.625", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"30.0" => {"Sch. 5S" => "0.25", "Sch. 10" => "0.312", "Sch. 10S" => "0.312", "Sch. 20" => "0.5", "Sch. 30" =>"0.625","Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"32.0" => {"Sch. 10" => "0.312","Sch. 20" => "0.5","Sch. 30" => "0.625","Sch. 40" => "0.688", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"34.0" => {"Sch. 10" => "0.312","Sch. 20" => "0.5","Sch. 30" => "0.625","Sch. 40" => "0.688", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"36.0" => {"Sch. 10" => "0.312","Sch. 20" => "0.5","Sch. 30" => "0.625","Sch. 40" => "0.750", "Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"48.0" => {"Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"56.0" => {"Sch. ST" => "0.375", "Sch. XS" =>"0.5"},
			"72.0" => {"Sch. ST" => "0.375", "Sch. XS" =>"0.5"}
		}
	end

	def self.pipe_schedules
		[
			{:id => 1, :name => "Sch. 5S"},
			{:id => 2, :name => "Sch. 10"},
			{:id => 3, :name => "Sch. 10S"},
			{:id => 4, :name => "Sch. 20"},
			{:id => 5, :name => "Sch. 30"},
			{:id => 6, :name => "Sch. 40"},
			{:id => 7, :name => "Sch. 40S"},
			{:id => 8, :name => "Sch. 40ST"},
			{:id => 9, :name => "Sch. 60"},
			{:id => 10, :name => "Sch. 60XS"},      
			{:id => 11, :name => "Sch. 80"},
			{:id => 12, :name => "Sch. 80S"},
			{:id => 13, :name => "Sch. 80XS"},
			{:id => 14, :name => "Sch. 100"},
			{:id => 15, :name => "Sch. 120"},      
			{:id => 16, :name => "Sch. 140"},
			{:id => 17, :name => "Sch. 160"},
			{:id => 18, :name => "Sch. ST"},
			{:id => 19, :name => "Sch. XS"},
			{:id => 20, :name => "Sch. XX"},
		]
	end

	def self.pipe_size_cycle
		[
			{:pipe_size => "0.125", :pipe_schedule => "Sch. 40", :diameter => "0.269"},
			{:pipe_size => "0.25", :pipe_schedule => "Sch. 40", :diameter => "0.364"},
			{:pipe_size => "0.375", :pipe_schedule => "Sch. 40", :diameter => "0.493"}, 
			{:pipe_size => "0.5", :pipe_schedule => "Sch. 40", :diameter => "0.622"},
			{:pipe_size => "0.75", :pipe_schedule => "Sch. 40", :diameter => "0.824"},
			{:pipe_size => "1", :pipe_schedule => "Sch. 40", :diameter => "1.049"},
			{:pipe_size => "1.25", :pipe_schedule => "Sch. 40", :diameter => "1.38"},
			{:pipe_size => "1.5", :pipe_schedule => "Sch. 40", :diameter => "1.61"},
			{:pipe_size => "2", :pipe_schedule => "Sch. 40", :diameter => "2.067"},
			{:pipe_size => "2.5", :pipe_schedule => "Sch. 40", :diameter => "2.469"},
			{:pipe_size => "3", :pipe_schedule => "Sch. 40", :diameter => "3.068"},
			{:pipe_size => "3.5", :pipe_schedule => "Sch. 40", :diameter => "3.548"},
			{:pipe_size => "4", :pipe_schedule => "Sch. 40", :diameter => "4.026"},
			{:pipe_size => "5", :pipe_schedule => "Sch. 40", :diameter => "5.047"},
			{:pipe_size => "6", :pipe_schedule => "Sch. 40", :diameter => "6.065"},
			{:pipe_size => "8", :pipe_schedule => "Sch. 40", :diameter => "7.981"},
			{:pipe_size => "10", :pipe_schedule => "Sch. 40", :diameter => "10.02"},
			{:pipe_size => "12", :pipe_schedule => "Sch. 40", :diameter => "11.938"},
			{:pipe_size => "14", :pipe_schedule => "Sch. 40", :diameter => "13.124"},
			{:pipe_size => "16", :pipe_schedule => "Sch. 40", :diameter => "15"},
			{:pipe_size => "18", :pipe_schedule => "Sch. 40", :diameter => "16.876"},
			{:pipe_size => "20", :pipe_schedule => "Sch. 40", :diameter => "18.812"},
			{:pipe_size => "22", :pipe_schedule => "Sch. 20", :diameter => "21.25"},
			{:pipe_size => "24", :pipe_schedule => "Sch. 40", :diameter => "22.624"},
			{:pipe_size => "26", :pipe_schedule => "Sch. 20", :diameter => "25"},
			{:pipe_size => "28", :pipe_schedule => "Sch. 20", :diameter => "27"},
			{:pipe_size => "30", :pipe_schedule => "Sch. 20", :diameter => "29"},
			{:pipe_size => "32", :pipe_schedule => "Sch. 20", :diameter => "31"},
			{:pipe_size => "34", :pipe_schedule => "Sch. 20", :diameter => "33"},
			{:pipe_size => "36", :pipe_schedule => "Sch. 20", :diameter => "35"},
			{:pipe_size => "48", :pipe_schedule => "", :diameter => "47"},
			{:pipe_size => "56", :pipe_schedule => "", :diameter => "51"},
			{:pipe_size => "72", :pipe_schedule => "", :diameter => "71"}
		]
	end

	def self.reynold_number(id)
		line_sizing = LineSizing.find(id)
		nre = []
		pipe_id = []
		(0..32).each do |k|
			pipe_id[k] = self.pipe_size_cycle[k][:diameter].to_f

			if line_sizing.liquid_viscosity.nil? && line_sizing.flowrate.nil?
			nre[k] = (6.316 * 1.0) / ( pipe_id[k] * 1.0)
			elsif line_sizing.liquid_viscosity.nil?
			nre[k] = (6.316 * line_sizing.flowrate) / ( pipe_id[k] * 1.0)
			elsif line_sizing.flowrate.nil?
			nre[k] = (6.316 * 1.0) / ( pipe_id[k] * line_sizing.liquid_viscosity)
			else
			nre[k] = (6.316 * line_sizing.flowrate) / ( pipe_id[k] * line_sizing.liquid_viscosity)
			end
			#raise line_sizing.liquid_viscosity.to_yaml
			#raise nre[k].to_yaml
		end
		return nre
	end

	#method getting form module 5  
	def self.determine_pipe_diameter(pipe_size, pipe_schedule)    
		pipe_id = 0
		if pipe_size == 0.125 && pipe_schedule == "Sch. 10S"
			pipe_d = 0.307
		elsif pipe_size == 0.125 && pipe_schedule == "Sch. 40ST"
			pipe_d = 0.269
		elsif pipe_size == 0.125 && pipe_schedule == "Sch. 40S"
			pipe_d = 0.269
		elsif pipe_size == 0.125 && pipe_schedule == "Sch. 80XS"
			pipe_d = 0.215
		elsif pipe_size == 0.125 && pipe_schedule == "Sch. 80S"
			pipe_d = 0.215

		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 40"
			pipe_d = 0.364
		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 80"
			pipe_d = 0.302
		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 10S"
			pipe_d = 0.41
		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 40ST"
			pipe_d = 0.364
		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 40S"
			pipe_d = 0.364
		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 80XS"
			pipe_d = 0.302
		elsif pipe_size == 0.25 && pipe_schedule == "Sch. 80S"
			pipe_d = 0.302

		elsif pipe_size == 0.375 && pipe_schedule == "Sch. 10S"
			pipe_d = 0.545
		elsif pipe_size == 0.375 && pipe_schedule == "Sch. 40ST"
			pipe_d = 0.493
		elsif pipe_size == 0.375 && pipe_schedule == "Sch. 40S"
			pipe_d = 0.493
		elsif pipe_size == 0.375 && pipe_schedule == "Sch. 80XS"
			pipe_d = 0.423
		elsif pipe_size == 0.375 && pipe_schedule == "Sch. 80S"
			pipe_d = 0.423

		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 5S"
			pipe_d = 0.71
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 10S"
			pipe_d = 0.674
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 40ST"
			pipe_d = 0.622
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 40S"
			pipe_d = 0.622
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 80XS"
			pipe_d = 0.546
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 80S"
			pipe_d = 0.546
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 80"
			pipe_d = 0.546
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. 160"
			pipe_d = 0.464
		elsif pipe_size == 0.5 && pipe_schedule == "Sch. XX"
			pipe_d = 0.252

		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 5S"
			pipe_d = 0.92
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 10S"
			pipe_d = 0.884
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 40ST"
			pipe_d = 0.824
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 40S"
			pipe_d = 0.824
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 40"
			pipe_d = 0.824
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 80XS"
			pipe_d = 0.742
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 80S"
			pipe_d = 0.742
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 80"
			pipe_d = 0.742
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. 160"
			pipe_d = 0.612
		elsif pipe_size == 0.75 && pipe_schedule == "Sch. XX"
			pipe_d = 0.434

		elsif pipe_size == 1 && pipe_schedule == "Sch. 5S"
			pipe_d = 1.185
		elsif pipe_size == 1 && pipe_schedule == "Sch. 10S"
			pipe_d = 1.097
		elsif pipe_size == 1 && pipe_schedule == "Sch. 40ST"
			pipe_d = 1.049
		elsif pipe_size == 1 && pipe_schedule == "Sch. 40S"
			pipe_d = 1.049
		elsif pipe_size == 1 && pipe_schedule == "Sch. 40"
			pipe_d = 1.049
		elsif pipe_size == 1 && pipe_schedule == "Sch. 80XS"
			pipe_d = 0.957
		elsif pipe_size == 1 && pipe_schedule == "Sch. 80S"
			pipe_d = 0.957
		elsif pipe_size == 1 && pipe_schedule == "Sch. 80"
			pipe_d = 0.957
		elsif pipe_size == 1 && pipe_schedule == "Sch. 160"
			pipe_d = 0.815
		elsif pipe_size == 1 && pipe_schedule == "Sch. XX"
			pipe_d = 0.599

		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 5S"
			pipe_d = 1.53
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 10S"
			pipe_d = 1.442
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 40ST"
			pipe_d = 1.38
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 40S"
			pipe_d = 1.38
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 40"
			pipe_d = 1.38
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 80XS"
			pipe_d = 1.278
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 80S"
			pipe_d = 1.278
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 80"
			pipe_d = 1.278
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. 160"
			pipe_d = 1.16
		elsif pipe_size == 1.25 && pipe_schedule == "Sch. XX"
			pipe_d = 0.896

		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 5S"
			pipe_d = 1.77
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 10S"
			pipe_d = 1.682
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 40ST"
			pipe_d = 1.61
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 40S"
			pipe_d = 1.61
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 40"
			pipe_d = 1.61
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 80XS"
			pipe_d = 1.5
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 80S"
			pipe_d = 1.5
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 80"
			pipe_d = 1.5
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. 160"
			pipe_d = 1.338
		elsif pipe_size == 1.5 && pipe_schedule == "Sch. XX"
			pipe_d = 1.1

		elsif pipe_size == 2 && pipe_schedule == "Sch. 5S"
			pipe_d = 2.245
		elsif pipe_size == 2 && pipe_schedule == "Sch. 10S"
			pipe_d = 2.157
		elsif pipe_size == 2 && pipe_schedule == "Sch. 40ST"
			pipe_d = 2.067    
		elsif pipe_size == 2 && pipe_schedule == "Sch. 40S"
			pipe_d = 2.067    
		elsif pipe_size == 2 && pipe_schedule == "Sch. 40"
			pipe_d = 2.067
		elsif pipe_size == 2 && pipe_schedule == "Sch. 80XS"
			pipe_d = 1.939
		elsif pipe_size == 2 && pipe_schedule == "Sch. 80S"
			pipe_d = 1.939
		elsif pipe_size == 2 && pipe_schedule == "Sch. 80"
			pipe_d = 1.939
		elsif pipe_size == 2 && pipe_schedule == "Sch. 160"
			pipe_d = 1.687
		elsif pipe_size == 2 && pipe_schedule == "Sch. XX"
			pipe_d = 1.503

		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 5S"
			pipe_d = 2.709
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 10S"
			pipe_d = 2.635    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 40ST"
			pipe_d = 2.469    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 40S"
			pipe_d = 2.469    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 40"
			pipe_d = 2.469    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 80XS"
			pipe_d = 2.323    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 80S"
			pipe_d = 2.323    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 80"
			pipe_d = 2.323    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. 160"
			pipe_d = 2.125    
		elsif pipe_size == 2.5 && pipe_schedule == "Sch. XX"
			pipe_d = 1.771

		elsif pipe_size == 3 && pipe_schedule == "Sch. 5S"
			pipe_d = 3.334
		elsif pipe_size == 3 && pipe_schedule == "Sch. 10S"
			pipe_d = 3.26    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 40ST"
			pipe_d = 3.068    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 40S"
			pipe_d = 3.068    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 40"
			pipe_d = 3.068    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 80XS"
			pipe_d = 2.9    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 80S"
			pipe_d = 2.9    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 80"
			pipe_d = 2.9    
		elsif pipe_size == 3 && pipe_schedule == "Sch. 160"
			pipe_d = 2.624    
		elsif pipe_size == 3 && pipe_schedule == "Sch. XX"
			pipe_d = 2.3

		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 5S"
			pipe_d = 3.834
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 10S"
			pipe_d = 3.76    
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 40ST"
			pipe_d = 3.548    
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 40S"
			pipe_d = 3.548    
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 40"
			pipe_d = 3.548    
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 80XS"
			pipe_d = 3.364    
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 80S"
			pipe_d = 3.364
		elsif pipe_size == 3.5 && pipe_schedule == "Sch. 80"
			pipe_d = 3.364

		elsif pipe_size == 4 && pipe_schedule == "Sch. 5S"
			pipe_d = 4.334
		elsif pipe_size == 4 && pipe_schedule == "Sch. 10S"
			pipe_d = 4.26    
		elsif pipe_size == 4 && pipe_schedule == "Sch. 40ST"
			pipe_d = 4.026
		elsif pipe_size == 4 && pipe_schedule == "Sch. 40S"
			pipe_d = 4.026
		elsif pipe_size == 4 && pipe_schedule == "Sch. 40"
			pipe_d = 4.026
		elsif pipe_size == 4 && pipe_schedule == "Sch. 80XS"
			pipe_d = 3.826
		elsif pipe_size == 4 && pipe_schedule == "Sch. 80S"
			pipe_d = 3.826
		elsif pipe_size == 4 && pipe_schedule == "Sch. 80"
			pipe_d = 3.826
		elsif pipe_size == 4 && pipe_schedule == "Sch. 120"
			pipe_d = 3.624
		elsif pipe_size == 4 && pipe_schedule == "Sch. 160"
			pipe_d = 3.438
		elsif pipe_size == 4 && pipe_schedule == "Sch. XX"
			pipe_d = 3.152

		elsif pipe_size == 5 && pipe_schedule == "Sch. 5S"
			pipe_d = 5.345
		elsif pipe_size == 5 && pipe_schedule == "Sch. 10S"
			pipe_d = 5.295
		elsif pipe_size == 5 && pipe_schedule == "Sch. 40ST"
			pipe_d = 5.047
		elsif pipe_size == 5 && pipe_schedule == "Sch. 40S"
			pipe_d = 5.047
		elsif pipe_size == 5 && pipe_schedule == "Sch. 40"
			pipe_d = 5.047
		elsif pipe_size == 5 && pipe_schedule == "Sch. 80XS"
			pipe_d = 4.813
		elsif pipe_size == 5 && pipe_schedule == "Sch. 80S"
			pipe_d = 4.813
		elsif pipe_size == 5 && pipe_schedule == "Sch. 80"
			pipe_d = 4.813
		elsif pipe_size == 5 && pipe_schedule == "Sch. 120"
			pipe_d = 4.563
		elsif pipe_size == 5 && pipe_schedule == "Sch. 160"
			pipe_d = 4.313    
		elsif pipe_size == 5 && pipe_schedule == "Sch. XX"
			pipe_d = 4.063

		elsif pipe_size == 6 && pipe_schedule == "Sch. 5S"
			pipe_d = 6.407
		elsif pipe_size == 6 && pipe_schedule == "Sch. 10S"
			pipe_d = 6.357
		elsif pipe_size == 6 && pipe_schedule == "Sch. 40ST"
			pipe_d = 6.065
		elsif pipe_size == 6 && pipe_schedule == "Sch. 40S"
			pipe_d = 6.065
		elsif pipe_size == 6 && pipe_schedule == "Sch. 40"
			pipe_d = 6.065
		elsif pipe_size == 6 && pipe_schedule == "Sch. 80XS"
			pipe_d = 5.761
		elsif pipe_size == 6 && pipe_schedule == "Sch. 80S"
			pipe_d = 5.761
		elsif pipe_size == 6 && pipe_schedule == "Sch. 80"
			pipe_d = 5.761
		elsif pipe_size == 6 && pipe_schedule == "Sch. 120"
			pipe_d = 5.501
		elsif pipe_size == 6 && pipe_schedule == "Sch. 160"
			pipe_d = 5.187
		elsif pipe_size == 6 && pipe_schedule == "Sch. XX"
			pipe_d = 4.897

		elsif pipe_size == 8 && pipe_schedule == "Sch. 5S"
			pipe_d = 8.407
		elsif pipe_size == 8 && pipe_schedule == "Sch. 10S"
			pipe_d = 8.329
		elsif pipe_size == 8 && pipe_schedule == "Sch. 20"
			pipe_d = 8.125
		elsif pipe_size == 8 && pipe_schedule == "Sch. 30"
			pipe_d = 8.071
		elsif pipe_size == 8 && pipe_schedule == "Sch. 40ST"
			pipe_d = 7.981
		elsif pipe_size == 8 && pipe_schedule == "Sch. 40S"
			pipe_d = 7.981
		elsif pipe_size == 8 && pipe_schedule == "Sch. 40"
			pipe_d = 7.981
		elsif pipe_size == 8 && pipe_schedule == "Sch. 60"
			pipe_d = 7.813
		elsif pipe_size == 8 && pipe_schedule == "Sch. 80XS"
			pipe_d = 7.625
		elsif pipe_size == 8 && pipe_schedule == "Sch. 80S"
			pipe_d = 7.625
		elsif pipe_size == 8 && pipe_schedule == "Sch. 100"
			pipe_d = 7.437
		elsif pipe_size == 8 && pipe_schedule == "Sch. 120"
			pipe_d = 7.187
		elsif pipe_size == 8 && pipe_schedule == "Sch. 140"
			pipe_d = 7.001
		elsif pipe_size == 8 && pipe_schedule == "Sch. XX"
			pipe_d = 6.875
		elsif pipe_size == 8 && pipe_schedule == "Sch. 160"
			pipe_d = 6.813

		elsif pipe_size == 10 && pipe_schedule == "Sch. 5S"
			pipe_d = 10.482
		elsif pipe_size == 10 && pipe_schedule == "Sch. 10S"
			pipe_d = 10.42
		elsif pipe_size == 10 && pipe_schedule == "Sch. 20"
			pipe_d = 10.25
		elsif pipe_size == 10 && pipe_schedule == "Sch. 30"
			pipe_d = 10.136
		elsif pipe_size == 10 && pipe_schedule == "Sch. 40ST"
			pipe_d = 10.02
		elsif pipe_size == 10 && pipe_schedule == "Sch. 40S"
			pipe_d = 10.02
		elsif pipe_size == 10 && pipe_schedule == "Sch. 40"
			pipe_d = 10.02
		elsif pipe_size == 10 && pipe_schedule == "Sch. 80S"
			pipe_d = 9.75
		elsif pipe_size == 10 && pipe_schedule == "Sch. 60XS"
			pipe_d = 9.75
		elsif pipe_size == 10 && pipe_schedule == "Sch. 80"
			pipe_d = 9.562
		elsif pipe_size == 10 && pipe_schedule == "Sch. 100"
			pipe_d = 9.312
		elsif pipe_size == 10 && pipe_schedule == "Sch. 120"
			pipe_d = 9.062
		elsif pipe_size == 10 && pipe_schedule == "Sch. 140"
			pipe_d = 8.75
		elsif pipe_size == 10 && pipe_schedule == "Sch. XX"
			pipe_d = 8.75
		elsif pipe_size == 10 && pipe_schedule == "Sch. 160"
			pipe_d = 8.5

		elsif pipe_size == 12 && pipe_schedule == "Sch. 5S"
			pipe_d = 12.438
		elsif pipe_size == 12 && pipe_schedule == "Sch. 10S"
			pipe_d = 12.39
		elsif pipe_size == 12 && pipe_schedule == "Sch. 20"
			pipe_d = 12.25
		elsif pipe_size == 12 && pipe_schedule == "Sch. 30"
			pipe_d = 12.09
		elsif pipe_size == 12 && pipe_schedule == "Sch. ST"
			pipe_d = 12
		elsif pipe_size == 12 && pipe_schedule == "Sch. 40S"
			pipe_d = 12
		elsif pipe_size == 12 && pipe_schedule == "Sch. 40"
			pipe_d = 11.938
		elsif pipe_size == 12 && pipe_schedule == "Sch. XS"
			pipe_d = 11.75
		elsif pipe_size == 12 && pipe_schedule == "Sch. 80S"
			pipe_d = 11.75
		elsif pipe_size == 12 && pipe_schedule == "Sch. 60"
			pipe_d = 11.626
		elsif pipe_size == 12 && pipe_schedule == "Sch. 80"
			pipe_d = 11.374
		elsif pipe_size == 12 && pipe_schedule == "Sch. 100"
			pipe_d = 11.062
		elsif pipe_size == 12 && pipe_schedule == "Sch. 120"
			pipe_d = 10.75
		elsif pipe_size == 12 && pipe_schedule == "Sch. XX"
			pipe_d = 10.75
		elsif pipe_size == 12 && pipe_schedule == "Sch. 140"
			pipe_d = 10.5
		elsif pipe_size == 12 && pipe_schedule == "Sch. 160"
			pipe_d = 10.126

		elsif pipe_size == 14 && pipe_schedule == "Sch. 5S"
			pipe_d = 13.686
		elsif pipe_size == 14 && pipe_schedule == "Sch. 10S"
			pipe_d = 13.624
		elsif pipe_size == 14 && pipe_schedule == "Sch. 10"
			pipe_d = 13.5
		elsif pipe_size == 14 && pipe_schedule == "Sch. 20"
			pipe_d = 13.376
		elsif pipe_size == 14 && pipe_schedule == "Sch. 30"
			pipe_d = 13.25
		elsif pipe_size == 14 && pipe_schedule == "Sch. ST"
			pipe_d = 13.25
		elsif pipe_size == 14 && pipe_schedule == "Sch. 40"
			pipe_d = 13.124
		elsif pipe_size == 14 && pipe_schedule == "Sch. XS"
			pipe_d = 13
		elsif pipe_size == 14 && pipe_schedule == "Sch. 60"
			pipe_d = 12.812
		elsif pipe_size == 14 && pipe_schedule == "Sch. 80"
			pipe_d = 12.5
		elsif pipe_size == 14 && pipe_schedule == "Sch. 100"
			pipe_d = 12.124
		elsif pipe_size == 14 && pipe_schedule == "Sch. 120"
			pipe_d = 11.812
		elsif pipe_size == 14 && pipe_schedule == "Sch. 140"
			pipe_d = 11.5
		elsif pipe_size == 14 && pipe_schedule == "Sch. 160"
			pipe_d = 11.188

		elsif pipe_size == 16 && pipe_schedule == "Sch. 5S"
			pipe_d = 15.67
		elsif pipe_size == 16 && pipe_schedule == "Sch. 10S"
			pipe_d = 15.624
		elsif pipe_size == 16 && pipe_schedule == "Sch. 10"
			pipe_d = 15.5
		elsif pipe_size == 16 && pipe_schedule == "Sch. 20"
			pipe_d = 15.376
		elsif pipe_size == 16 && pipe_schedule == "Sch. 30"
			pipe_d = 15.25
		elsif pipe_size == 16 && pipe_schedule == "Sch. ST"
			pipe_d = 15.25
		elsif pipe_size == 16 && pipe_schedule == "Sch. 40"
			pipe_d = 15
		elsif pipe_size == 16 && pipe_schedule == "Sch. XS"
			pipe_d = 15
		elsif pipe_size == 16 && pipe_schedule == "Sch. 60"
			pipe_d = 14.688
		elsif pipe_size == 16 && pipe_schedule == "Sch. 80"
			pipe_d = 14.312
		elsif pipe_size == 16 && pipe_schedule == "Sch. 100"
			pipe_d = 13.938
		elsif pipe_size == 16 && pipe_schedule == "Sch. 120"
			pipe_d = 13.562
		elsif pipe_size == 16 && pipe_schedule == "Sch. 140"
			pipe_d = 13.124
		elsif pipe_size == 16 && pipe_schedule == "Sch. 160"
			pipe_d = 12.812

		elsif pipe_size == 18 && pipe_schedule == "Sch. 5S"
			pipe_d = 17.67
		elsif pipe_size == 18 && pipe_schedule == "Sch. 10S"
			pipe_d = 17.624
		elsif pipe_size == 18 && pipe_schedule == "Sch. 10"
			pipe_d = 17.5
		elsif pipe_size == 18 && pipe_schedule == "Sch. 20"
			pipe_d = 17.376
		elsif pipe_size == 18 && pipe_schedule == "Sch. ST"
			pipe_d = 17.25
		elsif pipe_size == 18 && pipe_schedule == "Sch. 30"
			pipe_d = 17.124
		elsif pipe_size == 18 && pipe_schedule == "Sch. XS"
			pipe_d = 17
		elsif pipe_size == 18 && pipe_schedule == "Sch. 40"
			pipe_d = 16.876
		elsif pipe_size == 18 && pipe_schedule == "Sch. 60"
			pipe_d = 16.5
		elsif pipe_size == 18 && pipe_schedule == "Sch. 80"
			pipe_d = 16.124
		elsif pipe_size == 18 && pipe_schedule == "Sch. 100"
			pipe_d = 15.688
		elsif pipe_size == 18 && pipe_schedule == "Sch. 120"
			pipe_d = 15.25
		elsif pipe_size == 18 && pipe_schedule == "Sch. 140"
			pipe_d = 14.876
		elsif pipe_size == 18 && pipe_schedule == "Sch. 160"
			pipe_d = 14.438

		elsif pipe_size == 20 && pipe_schedule == "Sch. 5S"
			pipe_d = 19.624
		elsif pipe_size == 20 && pipe_schedule == "Sch. 10S"
			pipe_d = 19.564
		elsif pipe_size == 20 && pipe_schedule == "Sch. 10"
			pipe_d = 19.5
		elsif pipe_size == 20 && pipe_schedule == "Sch. 20"
			pipe_d = 19.25
		elsif pipe_size == 20 && pipe_schedule == "Sch. ST"
			pipe_d = 19.25
		elsif pipe_size == 20 && pipe_schedule == "Sch. 30"
			pipe_d = 19
		elsif pipe_size == 20 && pipe_schedule == "Sch. XS"
			pipe_d = 19
		elsif pipe_size == 20 && pipe_schedule == "Sch. 40"
			pipe_d = 18.812
		elsif pipe_size == 20 && pipe_schedule == "Sch. 60"
			pipe_d = 18.376
		elsif pipe_size == 20 && pipe_schedule == "Sch. 80"
			pipe_d = 17.938
		elsif pipe_size == 20 && pipe_schedule == "Sch. 100"
			pipe_d = 17.438
		elsif pipe_size == 20 && pipe_schedule == "Sch. 120"
			pipe_d = 17
		elsif pipe_size == 20 && pipe_schedule == "Sch. 140"
			pipe_d = 16.5
		elsif pipe_size == 20 && pipe_schedule == "Sch. 160"
			pipe_d = 16.062 

		elsif pipe_size == 22 && pipe_schedule == "Sch. 5S"
			pipe_d = 21.624
		elsif pipe_size == 22 && pipe_schedule == "Sch. 10S"
			pipe_d = 21.564
		elsif pipe_size == 22 && pipe_schedule == "Sch. 10"
			pipe_d = 21.5
		elsif pipe_size == 22 && pipe_schedule == "Sch. 20"
			pipe_d = 21.25
		elsif pipe_size == 22 && pipe_schedule == "Sch. ST"
			pipe_d = 21.25
		elsif pipe_size == 22 && pipe_schedule == "Sch. 30"
			pipe_d = 21
		elsif pipe_size == 22 && pipe_schedule == "Sch. XS"
			pipe_d = 21
		elsif pipe_size == 22 && pipe_schedule == "Sch. 60"
			pipe_d = 20.25
		elsif pipe_size == 22 && pipe_schedule == "Sch. 80"
			pipe_d = 19.75
		elsif pipe_size == 22 && pipe_schedule == "Sch. 100"
			pipe_d = 19.25
		elsif pipe_size == 22 && pipe_schedule == "Sch. 120"
			pipe_d = 18.75
		elsif pipe_size == 22 && pipe_schedule == "Sch. 140"
			pipe_d = 18.25
		elsif pipe_size == 22 && pipe_schedule == "Sch. 160"
			pipe_d = 17.75

		elsif pipe_size == 24 && pipe_schedule == "Sch. 5S"
			pipe_d = 23.565
		elsif pipe_size == 24 && pipe_schedule == "Sch. 10"
			pipe_d = 23.5
		elsif pipe_size == 24 && pipe_schedule == "Sch. 10S"
			pipe_d = 23.5
		elsif pipe_size == 24 && pipe_schedule == "Sch. 20"
			pipe_d = 23.25
		elsif pipe_size == 24 && pipe_schedule == "Sch. ST"
			pipe_d = 23.25
		elsif pipe_size == 24 && pipe_schedule == "Sch. XS"
			pipe_d = 23
		elsif pipe_size == 24 && pipe_schedule == "Sch. 30"
			pipe_d = 22.876
		elsif pipe_size == 24 && pipe_schedule == "Sch. 40"
			pipe_d = 22.624
		elsif pipe_size == 24 && pipe_schedule == "Sch. 60"
			pipe_d = 22.062
		elsif pipe_size == 24 && pipe_schedule == "Sch. 80"
			pipe_d = 21.562
		elsif pipe_size == 24 && pipe_schedule == "Sch. 100"
			pipe_d = 20.938
		elsif pipe_size == 24 && pipe_schedule == "Sch. 120"
			pipe_d = 20.376
		elsif pipe_size == 24 && pipe_schedule == "Sch. 140"
			pipe_d = 19.876
		elsif pipe_size == 24 && pipe_schedule == "Sch. 160"
			pipe_d = 19.312

		elsif pipe_size == 26 && pipe_schedule == "Sch. 10"
			pipe_d = 25.376
		elsif pipe_size == 26 && pipe_schedule == "Sch. ST"
			pipe_d = 25.25
		elsif pipe_size == 26 && pipe_schedule == "Sch. XS"
			pipe_d = 25
		elsif pipe_size == 26 && pipe_schedule == "Sch. 20"
			pipe_d = 25

		elsif pipe_size == 28 && pipe_schedule == "Sch. 10"
			pipe_d = 27.376    
		elsif pipe_size == 28 && pipe_schedule == "Sch. ST"
			pipe_d = 27.25    
		elsif pipe_size == 28 && pipe_schedule == "Sch. XS"
			pipe_d = 27    
		elsif pipe_size == 28 && pipe_schedule == "Sch. 20"
			pipe_d = 27    
		elsif pipe_size == 28 && pipe_schedule == "Sch. 30"
			pipe_d = 26.75

		elsif pipe_size == 30 && pipe_schedule == "Sch. 5S"
			pipe_d = 29.5    
		elsif pipe_size == 30 && pipe_schedule == "Sch. 10"
			pipe_d = 29.376
		elsif pipe_size == 30 && pipe_schedule == "Sch. 10S"
			pipe_d = 29.376
		elsif pipe_size == 30 && pipe_schedule == "Sch. ST"
			pipe_d = 29.25
		elsif pipe_size == 30 && pipe_schedule == "Sch. 20"
			pipe_d = 29
		elsif pipe_size == 30 && pipe_schedule == "Sch. XS"
			pipe_d = 29
		elsif pipe_size == 30 && pipe_schedule == "Sch. 30"
			pipe_d = 28.75

		elsif pipe_size == 32 && pipe_schedule == "Sch. 10"
			pipe_d = 31.376
		elsif pipe_size == 32 && pipe_schedule == "Sch. ST"
			pipe_d = 31.25
		elsif pipe_size == 32 && pipe_schedule == "Sch. XS"
			pipe_d = 31
		elsif pipe_size == 32 && pipe_schedule == "Sch. 20"
			pipe_d = 31
		elsif pipe_size == 32 && pipe_schedule == "Sch. 30"
			pipe_d = 30.75
		elsif pipe_size == 32 && pipe_schedule == "Sch. 40"
			pipe_d = 30.624

		elsif pipe_size == 34 && pipe_schedule == "Sch. 10"
			pipe_d = 33.312
		elsif pipe_size == 34 && pipe_schedule == "Sch. ST"
			pipe_d = 33.25
		elsif pipe_size == 34 && pipe_schedule == "Sch. XS"
			pipe_d = 33
		elsif pipe_size == 34 && pipe_schedule == "Sch. 20"
			pipe_d = 33
		elsif pipe_size == 34 && pipe_schedule == "Sch. 30"
			pipe_d = 32.75
		elsif pipe_size == 34 && pipe_schedule == "Sch. 40"
			pipe_d = 32.624

		elsif pipe_size == 36 && pipe_schedule == "Sch. 10"
			pipe_d = 35.367
		elsif pipe_size == 36 && pipe_schedule == "Sch. ST"
			pipe_d = 35.25
		elsif pipe_size == 36 && pipe_schedule == "Sch. XS"
			pipe_d = 35
		elsif pipe_size == 36 && pipe_schedule == "Sch. 20"
			pipe_d = 35
		elsif pipe_size == 36 && pipe_schedule == "Sch. 30"
			pipe_d = 34.75
		elsif pipe_size == 36 && pipe_schedule == "Sch. 40"
			pipe_d = 34.5    
		end

		return pipe_d
	end

  def self.orifice_meter(orifice_type, beta, nreynolds, d,pipe_id=nil)
  	b = 0.0
  	n = 0.0
  	nred = nreynolds
  	cinf = 0.0
 
    # Determine Discharge Coefficient (Infinitity) for Equation 10-10, Darby
    if orifice_type == "Flow Element - Orifice Plate (Corner Tap)"
      cinf = 0.5959 + (0.0312 * (beta ** 2.1)) - (0.184 * (beta ** 8))
      b = 91.71 * (beta ** 2.5)
      n=0.75
      orifice_type = "Corner Taps"
    elsif  orifice_type == "Flow Element - Orifice Plate (Flange Tap with D > 2.3 inches)" || orifice_type == "Flow Element - Orifice Plate (Flange Tap with D > 58.4 millimeters)"
      cinf = 0.5959 + (0.0312 * (beta ** 2.1)) - (0.184 * (beta ** 8)) + (0.09 * ((beta ** 4) / (pipe_id * (1 - (beta ** 4))))) - (0.0337 * ((beta ** 3) / pipe_id))
      b = 91.71 * (beta ** 2.5)
      n=0.75
      orifice_type = "Flange Taps"
    elsif orifice_type == "Flow Element - Orifice Plate (Flange Tap with D >= 2 and D <= 2.3 inches)" || orifice_type == "Flow Element - Orifice Plate (Flange Tap with D >=50.8 and D <= 58.4 millimeters)"
      cinf = 0.5959 + (0.0312 * (beta ** 2.1)) - (0.184 * (beta ** 8)) +  (0.039 * ((beta ^ 4) / (1 - beta ** 4))) - (0.0337 * ((beta ** 3) / pipe_id))
      b = 91.71 * (beta ** 2.5)
      n=0.75
      orifice_type = "Flange Taps"
    elsif orifice_type == "Flow Element - Orifice Plate (D and D/2 Taps) or Radius Taps"
      cinf = 0.5959 + (0.0312 * (beta ** 2.1)) - (0.184 * (beta ** 8)) + (0.039 * ((beta ** 4) / (1 - beta ** 4))) - (0.0158 * (beta ** 3))
      b = 91.71 * (beta ** 2.5)
      n = 0.75
      orifice_type = "Radius Taps"
    elsif orifice_type ==  "Flow Element - Orifice Plate (2D and 8D Taps or Pipe Taps)"
      cinf = 0.5959 + (0.461 * (beta ** 2.1)) + (0.48 * (beta ** 8)) + (0.039 * ((beta ** 4) / (1 - (beta ** 4))))
      b = 91.71 * (beta ** 2.5)
      n = 0.75
      orifice_type = "Pipe Taps"
    elsif orifice_type == "Flow Element - Venturi (Machined Inlet)"
      cinf = 0.995
      b = 0
      n = 0
      orifice_type = "Machine Inlet"
    elsif orifice_type == "Flow Element - Venturi (Rough Cast Inlet)"
      cinf = 0.984
      b = 0
      n = 0
      orifice_type = "Rough Cast"
    elsif orifice_type == "Flow Element - Venturi (Rough Welded Sheet - Iron Inlet)"
      cinf = 0.985
      b = 0
      n = 0
      orifice_type = "Rough Welded Sheet Iron Inlet"
    elsif orifice_type == "Flow Element - Nozzle (ASME Long Radius)"
      cinf = 0.9975
      b = -6.53 * (beta ** 0.5)
      n = 0.5
      orifice_type = "ASME"
    elsif orifice_type == "Flow Element - Nozzle(ISA)"
      cinf = 0.99 - (0.2262 * (beta ** 4.1))
      b = 1708 - (8936 * beta) + (19779 * (beta ** 4.7))
      n = 1.15
      orifice_type = "ISA"
    elsif orifice_type == "Flow Element - Nozzle (Venturi Nozzle - ISA Inlet)"
      cinf = 0.9858 - (0.195 * (beta ** 4.5))
      b = 0
      n = 0
      orifice_type = "Venturi Nozzle"
    elsif orifice_type == "Flow Element - Universal Venturi Tube"
      cinf = 0.9797
      b = 0
      n = 0
      orifice_type = "Universal Venturi Tube"
    elsif orifice_type == "Flow Element - Lo-Loss Tube"
      cinf = 1.05 - (0.417 * beta) + (0.564 * (beta ** 2)) - (0.514 * (beta ** 3))
      b = 0
      n= 0
      orifice_type = "Lo-Loss"
    end

    # Changing Pipe Size from string to value
    cd = 0.0

    puts nred


    #  Determine Discharge Coefficient
    if ["Radius Taps","Corner Taps","Flange Taps"].include?(orifice_type)
      if d >= 2.0 && d <= 36.0
        if beta >= 0.2 && beta <= 0.75
          if nred >= 10.0 ** 4 && nred <= 10.0 ** 7
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Pipe Taps"
      if d >= 2 && d <= 36
        if beta >= 0.2 && beta <= 0.75
          if nred >= (10 ** 4) && nred <= (10 ** 7)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Machine Inlet"
      if d >= 2 && d <= 10
        if beta >= 0.4 && beta <= 0.75
          if nred >= (2 * 10 ** 5) && nred <= (10 ** 6)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Rough Cast"
      if d >= 4 && d <= 32
        if beta >= 0.3 && beta <= 0.75
          if nred >= (2 * (10 ** 5)) && nred <= (10 ** 6)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Rough Welded Sheet Iron Inlet"
      if d >= 8 && d <= 48
        if beta >= 0.4 && beta <= 0.7
          if nred >= (2 * (10 ** 5)) && nred <= (10 ** 6)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "ASME"
      if d >= 2 && d <= 16
        if beta >= 0.25 && beta <= 0.75
          if nred >= (10 ** 4) && nred <= (10 ** 7)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "ISA"
      if d >= 2 && d <= 20
        if beta >= 0.3 && beta <= 0.75
          if nred >= (10 ** 5) && nred <= (10 ** 7)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Venturi Nozzle"
      if d >= 3 && d <= 20
        if beta >= 0.3 && beta <= 0.75
          if nred >= (2 * (10 ** 5)) && nred <= (2 * (10 ** 6))
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Universal Venturi Tube"
      if d >= 3
        if beta >= 0.2 && beta <= 0.75
          if nred >= 7.5 * (10 ** 4)
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    elsif orifice_type == "Lo-Loss"
      if d >= 3 && d <= 120
        if beta >= 0.35 && beta <= 0.85
          if nred >= (1.25 * (10 ** 5)) && nred <= (3.5 * (10 ** 6))
            cd = cinf + (b / (nred ** n))
          else
            message2=""
          end
        else
          message2=""
        end
        message2=""
      end
    end

    puts "cd = #{cd}"
    puts "orifice type = #{orifice_type}"
    puts "beta = #{beta}"
    puts "b = #{b}" 
    puts "n = #{n}"
    puts "cinf = #{cinf}"

    part1 = (cd * (beta ** 2))
    part2 = (beta **  4) * (1 - (cd ** 2))
    part3 = (1 - part2) **  0.5
    part4 = part3 / part1
    kf = (part4 - 1) ** 2 

    return kf
  end

	#method getting form module 71
   def self.resistance_coefficient(fitting_type, nreynolds, d, d1, d2, cv,dover_d,dorifice=nil,project=nil)
		kf = 0.0
		#dover_d = 0.0 if dover_d.nil?
		
		if fitting_type == "Pipe"
			kf = 0
		elsif fitting_type == "Valve - Gate (Full Bore)"
			k1 = 300.0
			ki = 0.037
			kd = 3.9
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Ball (Full Bore)"
			k1 = 300.0
			ki = 0.017
			kd = 3.5
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Globe (Full Bore)"
			k1 = 1500.0
			ki = 1.7
			kd = 3.6
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Angle (45&deg;, Full Bore)"
			k1 = 950.0
			ki = 0.25
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Angle (90&deg;, Full Bore)"
			k1 = 1000
			ki = 0.69
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Swing Check"
			k1 = 1500
			ki = 0.46
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Lift Check"
			k1 = 2000
			ki = 2.85
			kd = 3.8
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Plug (Branch Flow)"
			k1 = 500
			ki = 0.41
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Plug (Straight Through)"
			k1 = 300
			ki = 0.084
			kd = 3.9
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Plug (3 way Flow Through)"
			k1 = 300
			ki = 0.14
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Valve - Diaphragm (Dam Type)"
			k1 = 1000
			ki = 0.69
			kd = 4.9
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Through Branch (Threaded, r/D = 1)"
			k1 = 500
			ki = 0.274
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Through Branch (Threaded, r/D = 1.5)"
			k1 = 800
			ki = 0.14
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Through Branch (Flanged)"
			k1 = 800
			ki = 0.28
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Through Branch (Stub-In Branch)"
			k1 = 1000
			ki = 0.34
			kd = 4.0
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Run Through (Threaded)"
			k1 = 200
			ki = 0.091
			kd = 4.0
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Run Through (Flanged)"
			k1 = 150.0
			ki = 0.05
			kd = 4.0
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Tee - Run Through (Stub-In Branch)"
			k1 = 100
			ki = 0
			kd = 0
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Threaded, Standard)"
			k1 = 800.0
			ki = 0.14
			kd = 4.0
			kf = (k1 / nreynolds) + ki * (1.0 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Threaded, Long Radius)"
			k1 = 800
			ki = 0.071
			kd = 4.2
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 1)"
			k1 = 800
			ki = 0.091
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 2)"
			k1 = 800
			ki = 0.056
			kd = 3.9
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 4)"
			k1 = 800.0
			ki = 0.066
			kd = 3.9
			kf = (k1 / nreynolds) + ki * (1.0 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Flanged, Welded, Bend, r/D = 6)"
			k1 = 800
			ki = 0.075
			kd = 4.2
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Mitered, 1 Weld, 90&deg;)"
			k1 = 1000
			ki = 0.27
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Mitered, 2 Welds, 45&deg;)"
			k1 = 800
			ki = 0.068
			kd = 4.1
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 90&deg; (Mitered, 3 Welds, 30&deg;)"
			k1 = 800
			ki = 0.035
			kd = 4.2
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 45&deg; (Threaded, Standard)"
			k1 = 500
			ki = 0.071
			kd = 4.2
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 45&deg; (Long Radius)"
			k1 = 500
			ki = 0.052
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 45&deg; (Mitered, 1 Weld, 45&deg;)"
			k1 = 500
			ki = 0.086
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 45&deg; (Mitered, 2 Welds, 22.5&deg;)"
			k1 = 500
			ki = 0.052
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 180&deg; (Threaded, Close Return Bend)"
			k1 = 1000
			ki = 0.23
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 180&deg; (Flanged)"
			k1 = 1000
			ki = 0.12
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Elbow - 180&deg; (All)"
			k1 = 1000
			ki = 0.1
			kd = 4
			kf = (k1 / nreynolds) + ki * (1 + (kd / d ** 0.3))
		elsif fitting_type == "Contraction" #Coker

			if !dover_d.nil?
				d1 = d
				d2 = d1 * dover_d
			end

			part1 = 0.1 + (50.0 / nreynolds)

			if d1 > d2
				part2 = ((d1 / d2) ** 4.0) - 1.0
			else 
				part2 = 0.0
			end

			kf = part1 * part2

			if dover_d.nil?
				if d1 > d2
					dover_d = (d2 / d1).round(3)
				elsif d1 < d2
					dover_d = (d1 / d2).round(3)
				elsif d1 = d2
					dover_d = 1.0
				end
			end
		elsif fitting_type == "Expansion"
			if !dover_d.nil?
				d1 = d
				d2 = d1 / dover_d
			end

			part1 = 0.1 + (50.0 / nreynolds)
			part2 = 0.0

			if d1 < d2
				part2 = ((d1 / d2) ** 4.0) - 1.0
			elsif d1 > d2
				#message1 = MsgBox("The inlet pipe size and the outlet pipe size does not justify the presence of a expansion.  Please verify and update the piping configuration and sizes accordingly", vbOKOnly, "Inappropriate Fitting Entry")
				part2 = 0.0
			else
				part2 = 0.0
			end

			kf = part1 * part2

			if dover_d.nil?
				if d1 > d2
					dover_d = (d2 / d1).round(3)
				elsif d1 < d2
					dover_d = (d1 / d2).round(3)
				elsif d1 == d2
					dover_d = 1.0
				end
			end
		elsif fitting_type == "Entrance - Inward Projecting (Borda)"
			k1 = 160
			kinf = 1
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Entrance - Flush (Sharply Edged, r/D = 0)"
			k1 = 160
			kinf = 0.5
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Entrance - Flush (Rounded, r/D = 0.02)"
			k1 = 160
			kinf = 0.28
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Entrance - Flush (Rounded, r/D = 0.04)"
			k1 = 160
			kinf = 0.24
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Entrance - Flush (Rounded, r/D = 0.06)"
			k1 = 160
			kinf = 0.15
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Entrance - Flush (Rounded, r/D = 0.1)"
			k1 = 160
			kinf = 0.09
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Entrance - Flush (Rounded, r/D > 0.15)"
			k1 = 1
			kinf = 0.04
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Exit - Pipe"
			k1 = 0
			kinf = 1
			kf = (k1 / nreynolds) + kinf
		elsif fitting_type == "Rupture Disk"
			kf = 1.5
		elsif fitting_type == "Orifice"
			default_orifice_type = project.restriction_orifice_meter_default_type
			if default_orifice_type == "Flange Taps"
				if d > 2.3
					fittingtype == "Flow Element - Orifice Plate (Flange Tap with D > 2.3 inches)"
					beta = dorifice / d
					self.orifice_meter(fittingtype, beta, nreynolds, d, kf)
				elsif d >= 2.0 and d <= 2.3
					fittingtype == "Flow Element - Orifice Plate (Flange Tap with D >= 2 and D <= 2.3 inches)"
					beta = dorifice / d
					self.orifice_meter(fittingtype, beta, nreynolds, d, kf)
				end
			elsif default_orifice_type == "Corner Taps"
				fittingtype = "Flow Element - Orifice Plate (Corner Tap)"
				beta = dorifice / d
				self.orifice_meter(fittingtype, beta, nreynolds, d, kf)
			elsif default_orifice_type == "Radius Taps"
				fittingtype = "Flow Element - Orifice Plate (D and D/2 Taps)"
				beta = dorifice / d
				self.orifice_meter(fittingtype, beta, nreynolds, d, kf)
			elsif default_orifice_type == "Pipe Taps"
				fittingtype = "Flow Element - Orifice Plate (2D and 8D Taps or Pipe Taps)"
				beta = dorifice / d
				self.orifice_meter(fittingtype, beta, nreynolds, d, kf)
			end
		elsif fitting_type == "User Entered"
			#kf = InputBox("Enter a kf value for the generic fitting at Reynold Number of " & Round(nreynolds, 0) & ".", "Enter kf Value For Generic Fitting!") + 0
		elsif fitting_type == "Valve - Butterfly Valve (Full Bore)"
			k1 = 800
			kinf = 0.25
			kf = (k1 / nreynolds) + kinf * (1 + (1 / d))
		elsif fitting_type == "Sudden Expansion" #Coker

			if !dover_d.nil?
				d1 = d
				d2 = d1 / dover_d
			end

			if !d1.nil?  && !d2.nil?
				if d1 < d2
					beta_squared = (d1 ** 2.0) / (d2 ** 2.0)
				elsif d1 > d2
					beta_squared = (d2 ** 2.0) / (d1 ** 2.0)
				else
					beta_squared = 1.0
				end
			else
				#msg1 = MsgBox("The inlet pipe size and the outlet pipe size does not justify the presence of an expansion.  Please verify and update the piping configuration and sizes accordingly", vbOKOnly, "Inappropriate Fitting Entry")

			end

			kf = (1.0 - beta_squared) ** 2.0

			if dover_d.nil?
				if d1 > d2
					dover_d = (d2 / d1).round(3)
				elsif d1 < d2
					dover_d = (d1 / d2).round(3)
				elsif d1 == d2
					dover_d = 1.0
				end
			end
		elsif fitting_type == "Sudden Contraction" #Coker

			if !dover_d.nil?
				d1 = d
				d2 = d1 * dover_d
			end

			if !d1.nil?  && !d2.nil?
				if d1 < d2
					beta_squared = (d1 ** 2.0) / (d2 ** 2.0)
				elsif d1 > d2
					beta_squared = (d2 ** 2.0) / (d1 ** 2.0)
				else
					beta_squared = 1.0
				end
			else
				#msg1 = MsgBox("The inlet pipe size and the outlet pipe size does not justify the presence of an expansion.  Please verify and update the piping configuration and sizes accordingly", vbOKOnly, "Inappropriate Fitting Entry")
			end
			kf = 0.5 * (1.0 - beta_squared)

			if dover_d.nil?
				if d1 > d2
					dover_d = (d2 / d1).round(3)
				elsif d1 < d2
					dover_d = (d1 / d2).round(3)
				elsif d1 == d2
					dover_d = 1.0
				end
			end

		elsif fitting_type == "Equipment"
			kf = 0
		elsif fitting_type == "Control Valve"
			kf = ((29.9 * (d ** 2)) / cv) ** 2
		elsif fittingtype == "Flow Element - Venturi (Machined Inlet)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Venturi (Rough Cast Inlet)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Venturi (Rough Welded Sheet - Iron Inlet)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Universal Venturi Tube"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Lo-Loss Tube"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Nozzle (ASME Long Radius)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Nozzle(ISA)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Nozzle (Venturi Nozzle - ISA Inlet)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (Corner Tap)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (Flange Tap with D>2.3 inches)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (Flange Tap with D>58.4 millimeters)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (Flange Tap with D >=2 and D <=2.3 inches)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (Flange Tap with D >=50.8 and D <=58.4 millimeters)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (D and D/2 Taps)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		elsif fittingtype == "Flow Element - Orifice Plate (2D and 8D Taps or Pipe Taps)"
			beta = dorifice / d
			kf = self.orifice_meter(fittingtype, beta, nreynolds, d)
		end
		return {:kf => kf, :dover_d => dover_d}
  end

	def self.determine_nominal_pipe_size(rupture_diameter)
		pipe_size = 0
		pipe_schedule = ""
		proposed_diameter = 0

		if rupture_diameter > 0 && rupture_diameter <= 0.269
			pipe_size = 0.125
			pipe_schedule = "Sch. 40"
			proposed_diameter = 0.269
		elsif rupture_diameter > 0.269 && rupture_diameter <= 0.364
			pipe_size = 0.25
			pipe_schedule = "Sch. 40"
			proposed_diameter = 0.364
		elsif rupture_diameter > 0.364 && rupture_diameter <= 0.493
			pipe_size = 0.375
			pipe_schedule = "Sch. 40"
			proposed_diameter = 0.493
		elsif rupture_diameter > 0.493 && rupture_diameter <= 0.622
			pipe_size = 0.5
			pipe_schedule = "Sch. 40"
			proposed_diameter = 0.622
		elsif rupture_diameter > 0.622 && rupture_diameter <= 0.824
			pipe_size = 0.75
			pipe_schedule = "Sch. 40"
			proposed_diameter = 0.824
		elsif rupture_diameter > 0.824 && rupture_diameter <= 1.049
			pipe_size = 1
			pipe_schedule = "Sch. 40"
			proposed_diameter = 1.049
		elsif rupture_diameter > 1.049 && rupture_diameter <= 1.38
			pipe_size = 1.25
			pipe_schedule = "Sch. 40"
			proposed_diameter = 1.38
		elsif rupture_diameter > 1.38 && rupture_diameter <= 1.61
			pipe_size = 1.5
			pipe_schedule = "Sch. 40"
			proposed_diameter = 1.61
		elsif rupture_diameter > 1.61 && rupture_diameter <= 2.067
			pipe_size = 2
			pipe_schedule = "Sch. 40"
			proposed_diameter = 2.067
		elsif rupture_diameter > 2.067 && rupture_diameter <= 2.469
			pipe_size = 2.5
			pipe_schedule = "Sch. 40"
			proposed_diameter = 2.469
		elsif rupture_diameter > 2.469 && rupture_diameter <= 3.068
			pipe_size = 3
			pipe_schedule = "Sch. 40"
			proposed_diameter = 3.068
		elsif rupture_diameter > 3.068 && rupture_diameter <= 3.548
			pipe_size = 3.5
			pipe_schedule = "Sch. 40"
			proposed_diameter = 3.548
		elsif rupture_diameter > 3.548 && rupture_diameter <= 4.026
			pipe_size = 4
			pipe_schedule = "Sch. 40"
			proposed_diameter = 4.026
		elsif rupture_diameter > 4.026 && rupture_diameter <= 5.047
			pipe_size = 5
			pipe_schedule = "Sch. 40"
			proposed_diameter = 5.047
		elsif rupture_diameter > 5.047 && rupture_diameter <= 6.065
			pipe_size = 6
			pipe_schedule = "Sch. 40"
			proposed_diameter = 6.065
		elsif rupture_diameter > 6.065 && rupture_diameter <= 7.981
			pipe_size = 8
			pipe_schedule = "Sch. 40"
			proposed_diameter = 7.981
		elsif rupture_diameter > 7.981 && rupture_diameter <= 10.02
			pipe_size = "10"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 10.02
		elsif rupture_diameter > 10.02 && rupture_diameter <= 11.938
			pipe_size = "12"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 11.938
		elsif rupture_diameter > 11.938 && rupture_diameter <= 13.124
			pipe_size = "14"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 13.124
		elsif rupture_diameter > 13.124 && rupture_diameter <= 15#
			pipe_size = "16"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 15
		elsif rupture_diameter > 15 && rupture_diameter <= 16.876
			pipe_size = "18"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 16.876
		elsif rupture_diameter > 16.876 && rupture_diameter <= 18.812
			pipe_size = "20"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 18.812
		elsif rupture_diameter > 18.812 && rupture_diameter <= 21.25
			pipe_size = "22"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 21.25
		elsif rupture_diameter > 21.25 && rupture_diameter <= 22.624
			pipe_size = "24"
			pipe_schedule = "Sch. 40"
			proposed_diameter = 22.624
		elsif rupture_diameter > 22.624 && rupture_diameter <= 25
			pipe_size = "26"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 25
		elsif rupture_diameter > 25 && rupture_diameter <= 27
			pipe_size = "28"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 27
		elsif rupture_diameter > 27 && rupture_diameter <= 29
			pipe_size = "30"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 29
		elsif rupture_diameter > 29 && rupture_diameter <= 31
			pipe_size = "32"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 31
		elsif rupture_diameter > 31 && rupture_diameter <= 33
			pipe_size = "34"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 33
		elsif rupture_diameter > 33 && rupture_diameter <= 35
			pipe_size = "36"
			pipe_schedule = "Sch. 20"
			proposed_diameter = 35
		else
			pipe_size = rupture_diameter
			proposed_diameter = rupture_diameter
			pipe_schedule = "N/A"
		end
		return {:pipe_size=>pipe_size, :pipe_schedule=>pipe_schedule, :proposed_diameter=>proposed_diameter}
	end

	def self.liquid_resist(reynold, liquid_fraction)
		liquid_hold_up = 0
		if reynold == 100
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 85.204 * liquid_fraction + 0.3208
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 14.749 * liquid_fraction + 0.5307
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 488.66 * liquid_fraction ** 3 - 90.128 * liquid_fraction ** 2 + 5.2677 * liquid_fraction + 0.6408
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.2652 * liquid_fraction + 0.7355
			end
		elsif reynold == 500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 53.211 * liquid_fraction + 0.1086
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 14.749 * liquid_fraction + 0.2157
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 905.47 * liquid_fraction ** 3 - 190.87 * liquid_fraction ** 2 + 13.668 * liquid_fraction + 0.2515
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.4267 * liquid_fraction + 0.5734
			end
		elsif reynold == 1000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 57.845 * liquid_fraction + 0.0127
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 11.917 * liquid_fraction + 0.1617
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 841.37 * liquid_fraction ** 3 - 167.81 * liquid_fraction ** 2 + 12.109 * liquid_fraction + 0.1709
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.5075 * liquid_fraction + 0.4923
			end
		elsif reynold == 2500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 25.76 * liquid_fraction + 0.0238
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 18.807 * liquid_fraction + 0.0437
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 734.68 * liquid_fraction ** 3 - 109.56 * liquid_fraction ** 2 + 6.6302 * liquid_fraction + 0.1729
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.5708 * liquid_fraction + 0.4304
			end
		elsif reynold == 5000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 27.792 * liquid_fraction - 0.0028
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 14.686 * liquid_fraction + 0.0324
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 1141.8 * liquid_fraction ** 3 - 191.16 * liquid_fraction ** 2 + 10.832 * liquid_fraction + 0.0917
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.6341 * liquid_fraction + 0.3685
			end
		elsif reynold == 10000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 21.267 * liquid_fraction - 0.0071
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 13.392 * liquid_fraction + 0.0123
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 1084.9 * liquid_fraction ** 3 - 184.32 * liquid_fraction ** 2 + 10.577 * liquid_fraction + 0.0706
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.6744 * liquid_fraction + 0.3279
			end
		elsif reynold == 25000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 10.701 * liquid_fraction - 0.0014
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 9.0946 * liquid_fraction + 0.0042
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 501.4 * liquid_fraction ** 3 - 105.07 * liquid_fraction ** 2 + 8.159 * liquid_fraction + 0.0214
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.7805 * liquid_fraction + 0.2204
			end
		elsif reynold == 50000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				liquid_hold_up = 10.263 * liquid_fraction - 0.0091
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 5.9438 * liquid_fraction + 0.0017
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 43.376 * liquid_fraction ** 3 - 17.429 * liquid_fraction ** 2 + 3.4135 * liquid_fraction + 0.0306
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.8463 * liquid_fraction + 0.1535
			end
		elsif reynold == 100000
			if liquid_fraction >= 0.003 && liquid_fraction < 0.01
				liquid_hold_up = 2.7049 * liquid_fraction + 0.0033
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 481.29 * liquid_fraction ** 3 - 79.931 * liquid_fraction ** 2 + 5.4056 * liquid_fraction - 0.0165
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.8926 * liquid_fraction + 0.1064
			end
		elsif reynold == 200000
			if liquid_fraction >= 0.01 && liquid_fraction < 0.1
				liquid_hold_up = 1.3135 * liquid_fraction + 0.0035
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				liquid_hold_up = 0.9686 * liquid_fraction + 0.0307
			end
		elsif reynold >= 0.2 * 10 ** 6
			liquid_hold_up = liquid_fraction
		else
			liquid_hold_up = intermediate_hold_up(liquid_fraction, reynold)
		end

		return liquid_hold_up     
	end

	def self.intermediate_hold_up(liquid_fraction, reynold)
		liquid_hold_up = 0  
		high_reynold = 0
		low_reynold = 0
		reynold = reynold.to_f
		if reynold > 100 && reynold < 500
			low_reynold = 100
			high_reynold = 500
		elsif reynold > 500 && reynold < 1000
			low_reynold = 500
			high_reynold = 1000
		elsif reynold > 1000 && reynold < 2500
			low_reynold = 1000
			high_reynold = 2500
		elsif reynold > 2500 && reynold < 5000
			low_reynold = 2500
			high_reynold = 5000
		elsif reynold > 5000 && reynold < 10000
			low_reynold = 5000
			high_reynold = 10000
		elsif reynold > 10000 && reynold < 25000
			low_reynold = 10000
			high_reynold = 25000
		elsif reynold > 25000 && reynold < 50000
			low_reynold = 25000
			high_reynold = 50000
		elsif reynold > 50000 && reynold < 100000
			low_reynold = 50000
			high_reynold = 100000
		elsif reynold > 100000 && reynold < 200000
			low_reynold = 100000
			high_reynold = 200000
		end

		high_liquid_hold_up = high_reynold_calc(liquid_fraction, high_reynold)
		low_liquid_hold_up = low_reynold_calc(liquid_fraction, low_reynold)
		#slope = (high_liquid_hold_up - low_liquid_hold_up) / (high_reynold - low_reynold)
		slope = 1 #TggO
		interception = high_liquid_hold_up - (slope * high_reynold)
		liquid_hold_up = (slope * reynold) + interception

		return liquid_hold_up
	end

	def self.high_reynold_calc(liquid_fraction, high_reynold)
		high_liquid_hold_up = 0;    
		high_reynold = high_reynold.to_f
		if high_reynold == 100
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 85.204 * liquid_fraction + 0.3208
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 14.749 * liquid_fraction + 0.5307
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 488.66 * liquid_fraction ** 3 - 90.128 * liquid_fraction ** 2 + 5.2677 * liquid_fraction + 0.6408
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.2652 * liquid_fraction + 0.7355
			end
		elsif high_reynold == 500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 53.211 * liquid_fraction + 0.1086
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 14.749 * liquid_fraction + 0.2157
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 905.47 * liquid_fraction ** 3 - 190.87 * liquid_fraction ** 2 + 13.668 * liquid_fraction + 0.2515
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.4267 * liquid_fraction + 0.5734
			end
		elsif high_reynold == 1000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 57.845 * liquid_fraction + 0.0127
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 11.917 * liquid_fraction + 0.1617
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 841.37 * liquid_fraction ** 3 - 167.81 * liquid_fraction ** 2 + 12.109 * liquid_fraction + 0.1709
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.5075 * liquid_fraction + 0.4923
			end
		elsif high_reynold == 2500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 25.76 * liquid_fraction + 0.0238
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 18.807 * liquid_fraction + 0.0437
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 734.68 * liquid_fraction ** 3 - 109.56 * liquid_fraction ** 2 + 6.6302 * liquid_fraction + 0.1729
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.5708 * liquid_fraction + 0.4304
			end
		elsif high_reynold == 5000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 27.792 * liquid_fraction - 0.0028
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 14.686 * liquid_fraction + 0.0324
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 1141.8 * liquid_fraction ** 3 - 191.16 * liquid_fraction ** 2 + 10.832 * liquid_fraction + 0.0917
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.6341 * liquid_fraction + 0.3685
			end
		elsif high_reynold == 10000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 21.267 * liquid_fraction - 0.0071
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 13.392 * liquid_fraction + 0.0123
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 1084.9 * liquid_fraction ** 3 - 184.32 * liquid_fraction ** 2 + 10.577 * liquid_fraction + 0.0706
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.6744 * liquid_fraction + 0.3279
			end
		elsif high_reynold == 25000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 10.701 * liquid_fraction - 0.0014
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 9.0946 * liquid_fraction + 0.0042
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 501.4 * liquid_fraction ** 3 - 105.07 * liquid_fraction ** 2 + 8.159 * liquid_fraction + 0.0214
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.7805 * liquid_fraction + 0.2204
			end
		elsif high_reynold == 50000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				high_liquid_hold_up = 10.263 * liquid_fraction - 0.0091
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 5.9438 * liquid_fraction + 0.0017
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 43.376 * liquid_fraction ** 3 - 17.429 * liquid_fraction ** 2 + 3.4135 * liquid_fraction + 0.0306
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.8463 * liquid_fraction + 0.1535
			end
		elsif high_reynold == 100000
			if liquid_fraction >= 0.003 && liquid_fraction < 0.01
				high_liquid_hold_up = 2.7049 * liquid_fraction + 0.0033
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 481.29 * liquid_fraction ** 3 - 79.931 * liquid_fraction ** 2 + 5.4056 * liquid_fraction - 0.0165
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.8926 * liquid_fraction + 0.1064
			end
		elsif high_reynold == 200000
			if liquid_fraction >= 0.01 && liquid_fraction < 0.1
				high_liquid_hold_up = 1.3135 * liquid_fraction + 0.0035
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				high_liquid_hold_up = 0.9686 * liquid_fraction + 0.0307
			end
		elsif high_reynold >= 0.2 * 10 ** 6
			high_liquid_hold_up = liquid_fraction
		end

		return high_liquid_hold_up.to_f
	end

	def self.low_reynold_calc(liquid_fraction, low_reynold)
		low_reynold = low_reynold.to_f
		low_liquid_hold_up = 0
		if low_reynold == 100
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 85.204 * liquid_fraction + 0.3208
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 14.749 * liquid_fraction + 0.5307
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 488.66 * liquid_fraction ** 3 - 90.128 * liquid_fraction ** 2 + 5.2677 * liquid_fraction + 0.6408
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.2652 * liquid_fraction + 0.7355
			end
		elsif low_reynold == 500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 53.211 * liquid_fraction + 0.1086        
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 14.749 * liquid_fraction + 0.2157
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 905.47 * liquid_fraction ** 3 - 190.87 * liquid_fraction ** 2 + 13.668 * liquid_fraction + 0.2515
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.4267 * liquid_fraction + 0.5734
			end
		elsif low_reynold == 1000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 57.845 * liquid_fraction + 0.0127
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 11.917 * liquid_fraction + 0.1617
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 841.37 * liquid_fraction ** 3 - 167.81 * liquid_fraction ** 2 + 12.109 * liquid_fraction + 0.1709
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.5075 * liquid_fraction + 0.4923
			end
		elsif low_reynold == 2500
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 25.76 * liquid_fraction + 0.0238
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 18.807 * liquid_fraction + 0.0437
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 734.68 * liquid_fraction ** 3 - 109.56 * liquid_fraction ** 2 + 6.6302 * liquid_fraction + 0.1729
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.5708 * liquid_fraction + 0.4304
			end
		elsif low_reynold == 5000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 27.792 * liquid_fraction - 0.0028
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 14.686 * liquid_fraction + 0.0324
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 1141.8 * liquid_fraction ** 3 - 191.16 * liquid_fraction ** 2 + 10.832 * liquid_fraction + 0.0917
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.6341 * liquid_fraction + 0.3685
			end
		elsif low_reynold == 10000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 21.267 * liquid_fraction - 0.0071
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 13.392 * liquid_fraction + 0.0123
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 1084.9 * liquid_fraction ** 3 - 184.32 * liquid_fraction ** 2 + 10.577 * liquid_fraction + 0.0706
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.6744 * liquid_fraction + 0.3279
			end
		elsif low_reynold == 25000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 10.701 * liquid_fraction - 0.0014
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 9.0946 * liquid_fraction + 0.0042
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 501.4 * liquid_fraction ** 3 - 105.07 * liquid_fraction ** 2 + 8.159 * liquid_fraction + 0.0214
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.7805 * liquid_fraction + 0.2204
			end
		elsif low_reynold == 50000
			if liquid_fraction >= 0.001 && liquid_fraction < 0.003
				low_liquid_hold_up = 10.263 * liquid_fraction - 0.0091
			elsif liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 5.9438 * liquid_fraction + 0.0017
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 43.376 * liquid_fraction ** 3 - 17.429 * liquid_fraction ** 2 + 3.4135 * liquid_fraction + 0.0306
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.8463 * liquid_fraction + 0.1535
			end
		elsif low_reynold == 100000
			if liquid_fraction >= 0.003 && liquid_fraction < 0.01
				low_liquid_hold_up = 2.7049 * liquid_fraction + 0.0033
			elsif liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 481.29 * liquid_fraction ** 3 - 79.931 * liquid_fraction ** 2 + 5.4056 * liquid_fraction - 0.0165
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.8926 * liquid_fraction + 0.1064
			end
		elsif low_reynold == 200000
			if liquid_fraction >= 0.01 && liquid_fraction < 0.1
				low_liquid_hold_up = 1.3135 * liquid_fraction + 0.0035
			elsif liquid_fraction >= 0.1 && liquid_fraction <= 1
				low_liquid_hold_up = 0.9686 * liquid_fraction + 0.0307
			end
		elsif low_reynold >= 0.2 * 10 ** 6
			low_liquid_hold_up = liquid_fraction
		end
		return low_liquid_hold_up.to_f
	end
end
