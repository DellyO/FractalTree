#Nathan Dell

require 'rubygems'
require 'gosu'

module DellTree
	Width  = 800
	Height = 600        
	Fullscreen  = false 
	$split_range = []
	$shrink_range = []
	$trunk = []

	class Tree
	  
	  def initialize(window, color, bot_margin, x_coords, layer)
		@window = window
		
		@color = color
		@bot_margin = bot_margin
		@x = x_coords
		@layer = layer
		
		random_tree
		custom_tree
	  end
	  
	  #For when user decides to make a random tree
	  def random_tree
		#range of possible angle separations between branches
		angle_range = (40..50).to_a
		#range of possible shrinkage values, will have a decimal in front of it
		#shrink determines how short each branch is
		$shrink_range = (4..6).to_a
		#split determines how many levels of branches there are
		#below 5 makes a pretty weak tree
		#above 7 makes a big blob of black
		$split_range = (5..7).to_a
		
		#Determines how many branches the current one splits off into
		@num_splits = rand(4)+2
		
		#how long the "trunk" is, height is 600
		#this gets ugly above 250
		$trunk = (150..250).to_a
		
		@max_splits = $split_range[rand($split_range.length)]
		@shrink     = "0.#{$shrink_range[rand($shrink_range.length)]}".to_f
		@angle_of_separation = angle_range[rand(angle_range.length)]
		
		@branches = []
		@branches << [ [[@x, Height - @bot_margin], [@x, Height - $trunk[rand($trunk.length)]]] ] 
		
		puts "This output is from Random Tree"
		puts "Number of splits: #{@num_splits}"
		puts "Angle range: #{angle_range[0]} to #{angle_range[angle_range.length-1]}"
		puts "Shrink range: #{$shrink_range[0]} to #{$shrink_range[$shrink_range.length-1]}"
		puts "Split range: #{$split_range[0]} to #{$split_range[$split_range.length-1]}"
		puts "Initial branch length: #{$trunk[0]} to #{$trunk[$trunk.length-1]}"
		
	  end
	  
	  #For when user decides to customize their own tree
	  def custom_tree
		#if they haven't made a split range yet, make one for them
		if $split_range.empty?
			$split_range = (5..7).to_a
		end
		if $shrink_range.empty?
			$shrink_Range = (4..6).to_a
		end
		$trunk = (175..250).to_a
		
		@max_splits = $split_range[0]
		@shrink     = "0.#{$shrink_range[0]}".to_f
		#Height is 600, so y is in (0,600)
		@angle_of_separation = (@window.mouse_y / 10).to_i #this gives max of 60 degree angle, min of 0 (line)
		
		@branches = []
		@branches << [ [[@x, Height - @bot_margin], [@x, Height - $trunk[0]]] ]
		#Width is 800, so x is in (0,800)
		@num_splits = (((@window.mouse_x) / 100).to_i)+2 #this gives max of 8+2=10 splits, min of 2
		
		puts "This output is from Custom Tree"
		puts "Number of splits: #{@num_splits}"	
		puts "Angle of separation: #{@angle_of_separation}"
		puts "Shrink range: #{$shrink_range[0]} to #{$shrink_range[$shrink_range.length-1]}"
		puts "Split range: #{$split_range[0]} to #{$split_range[$split_range.length-1]}"		
		puts "Initial branch length: #{$trunk[0]} to #{$trunk[$trunk.length-1]}"
	  end
	  
	  def update
		last_section = @branches.last
			
		if @branches.length < @max_splits
		  new_branch  = []
		  
		  last_section.each do |b|
			old_x1, old_y1 = b[0][0], b[0][1]
			old_x2, old_y2 = b[1][0], b[1][1]
			old_length     = Gosu::distance(old_x1, old_y1, old_x2, old_y2)
			
			angle = (Gosu::angle(old_x1, old_y1, old_x2, old_y2)).to_i

			split_angle = (@angle_of_separation / 3) * 2
			far_angle = angle - @angle_of_separation
			
			new_x, new_y = old_x2, old_y2          
					
			@num_splits.times do |t|

				new_length = (old_length * @shrink).to_i
							
				branch_angle = far_angle + (split_angle * t)
			  
				branch_x = new_x + Gosu::offset_x(branch_angle, new_length)
				branch_y = new_y + Gosu::offset_y(branch_angle, new_length)
		  
				new_branch << [[new_x, new_y], [branch_x.to_i, branch_y.to_i]]
			end
		  end
		  
		  @branches << new_branch
		end
	  end
	  
	  def draw
		@branches.each do |a|
		  a.each do |b|
			@window.draw_line(b[0][0], b[0][1], @color, b[1][0], b[1][1], @color, @layer)
		  end
		end
	  end
	  
	end

	class Game < Gosu::Window
	  
	  def initialize
		super(Width, Height, Fullscreen)
		@tree = Tree.new(self, 0xFF000000, 10, Width / 2, 2)
		
		self.caption = "Dell Recursion Tree"

		@text = Gosu::Font.new(self, 'media/comic.ttf', 10)
	  end
	  
	  def update
		@tree.update    	
	  end
	  
	  def draw
		@tree.draw
		
		#my attempt at grass/sky...
		self.draw_quad(0, 0, Gosu::aqua, Width, 0, Gosu::aqua, 0, Height, Gosu::green, Width, Height, Gosu::green, 0)
		
		@text.draw("Press R to generate a random tree, or press C to customize (details below)", 10, 10, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Move mouse to the left/right for less/more branches", 10, 40, 1, 1.5, 1.5, 0xFF000000)	
		@text.draw("Press F1/F2 to decrease/increase how many levels of branches there are", 10, 50, 1, 1.5, 1.5, 0xFF000000)	
		@text.draw("Press F3/F4 to decrease/increase the size of a branch compared to its previous branch", 10, 60, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Press F5/F6 to decrease/increase the length of the trunk", 10, 70, 1, 1.5, 1.5, 0xFF000000)		
	  end
	  
	  def button_down(id)
		 if button_down? Gosu::KbEscape
		   close
		 end
		 if button_down? Gosu::KbR
		   @tree.random_tree
		 end
		 if button_down? Gosu::KbC
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF2
			$split_range[0] = $split_range[0] + 1
			$split_range[1] = $split_range[0]
			$split_range[2] = $split_range[0]
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF1
			$split_range[0] = $split_range[0] - 1
			$split_range[1] = $split_range[0]
			$split_range[2] = $split_range[0]
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF3
			$shrink_range[0] = $shrink_range[0] - 1
			$shrink_range[1] = $shrink_range[0]
			$shrink_range[2] = $shrink_range[0]
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF4
			$shrink_range[0] = $shrink_range[0] + 1
			$shrink_range[1] = $shrink_range[0]
			$shrink_range[2] = $shrink_range[0]
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF5
			$shrink_range[0] = $shrink_range[0] + 1
			$shrink_range[1] = $shrink_range[0]
			$shrink_range[2] = $shrink_range[0]
			@tree.custom_tree
		 end
	   end
	  
	end

Game.new.show
end