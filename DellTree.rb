#Nathan Dell

require 'rubygems'
require 'gosu'

module DellTree

	#Define how big the window is
	Width  = 800
	Height = 600        
	Fullscreen  = false 
	
	#Initialize global variables
	$split_range = []
	$shrink_range = []
	$trunk = []

	class Tree
	  
	  def initialize(window, color, bot_margin, x_coords, layer)
		@window = window
		
		@color = color
		#this will be our gap between bottom of tree and bottom of window
		@bot_margin = bot_margin
		@x = x_coords
		@layer = layer
		
		random_tree
		custom_tree
	  end
	  
	  #For when user decides to make a random tree
	  def random_tree
		#range of possible angle separations between branches
		#big range seems to be ok, 30 to 60 works nice
		$angle_of_separation = (30..60).to_a
		#range of possible shrinkage values, will have a decimal in front of it
		#shrink determines how short each branch is
		$shrink_range = (4..6).to_a
		#split determines how many levels of branches there are
		#below 5 makes a pretty weak tree
		#above 7 makes a big blob of black
		$split_range = (5..7).to_a
		
		#Determines how many branches the current one splits off into
		$num_splits = rand(4)+2
		
		#how long the "trunk" is, height is 600
		#this gets ugly above 250
		$trunk = (150..250).to_a
		
		#pick a random number from the split range to be used as the number of splits
		$split_range = $split_range[rand($split_range.length)]
		#as a decimal, find the factor we will multiply future branches by
		@shrink     = "0.#{$shrink_range[rand($shrink_range.length)]}".to_f
		#pick a random value for the angle of separation from the range
		$angle_of_separation = $angle_of_separation[rand($angle_of_separation.length)]
		
		#make a multidimensional array for branches
		@branches = []
		#start at the bottom, but not all the way down
		#move @x to the top of the trunk, ready for next branches
		@branches << [ [[@x, Height - @bot_margin], [@x, Height - $trunk[rand($trunk.length)]]] ] 
		
		puts "This output is from Random Tree"
		puts "Number of splits: #{$num_splits}"
		puts "Angle of separation: #{$angle_of_separation}"
		puts "Shrink range: #{$shrink_range[0]} to #{$shrink_range[$shrink_range.length-1]}"
		puts "Split range: #{$split_range}"
		puts "Initial branch length: #{$trunk[0]} to #{$trunk[$trunk.length-1]}"
		
	  end
	  
	  #For when user decides to customize their own tree
	  def custom_tree
		#if they haven't made a shrink range/trunk yet, make one for them
		if $shrink_range.empty?
			$shrink_Range = (4..6).to_a
		end
		if $trunk.empty?
			$trunk = (175..250).to_a
		end
		
		@shrink     = "0.#{$shrink_range[0]}".to_f
		#Height is 600, so y is in (0,600)
		$angle_of_separation = (@window.mouse_y / 10).to_i #this gives max of 60 degree angle, min of 0 (line)
		
		@branches = []
		@branches << [ [[@x, Height - @bot_margin], [@x, Height - $trunk[0]]] ]
		#Width is 800, so x is in (0,800)
		$num_splits = (((@window.mouse_x) / 100).to_i)+2 #this gives max of 8+2=10 splits, min of 2
		
		puts "This output is from Custom Tree"
		puts "Number of splits: #{$num_splits}"	
		puts "Angle of separation: #{$angle_of_separation}"
		puts "Shrink range: #{$shrink_range[0]} to #{$shrink_range[$shrink_range.length-1]}"
		puts "Split range: #{$split_range}"		
		puts "Initial branch length: #{$trunk[0]} to #{$trunk[$trunk.length-1]}"
	  end
	  
	  def update
		#find where we are on the tree
		last_section = @branches.last
			
		#use split range to determine levels of branches, or "how many times it splits"
		if @branches.length < $split_range
		  new_branch  = []
		  
		  last_section.each do |b|
			#gather both of line's x,y coordinates
			old_x1, old_y1 = b[0][0], b[0][1]
			old_x2, old_y2 = b[1][0], b[1][1]
			#gather line's length
			old_length     = Gosu::distance(old_x1, old_y1, old_x2, old_y2)
			#gather line's angle
			angle = (Gosu::angle(old_x1, old_y1, old_x2, old_y2)).to_i
			
			#determine new split angle
			split_angle = $angle_of_separation
			far_angle = angle - $angle_of_separation
			
			#new starting point is old ending point
			new_x, new_y = old_x2, old_y2          
					
			#do this for however many branches are on that level
			$num_splits.times do |t|
				#shrink new branch
				new_length = (old_length * @shrink).to_i
				#angle new branch
				branch_angle = far_angle + (split_angle * t)	
				#calculate new x,y ending coordinates
				branch_x = new_x + Gosu::offset_x(branch_angle, new_length)
				branch_y = new_y + Gosu::offset_y(branch_angle, new_length)
				#add new data to new branch
				new_branch << [[new_x, new_y], [branch_x.to_i, branch_y.to_i]]
			end
		  end
		  #add new branch to tree
		  @branches << new_branch
		end
	  end
	  
	  #function to output the lines as a drawing
	  def draw
		@branches.each do |a|
		  a.each do |b|
			@window.draw_line(b[0][0], b[0][1], @color, b[1][0], b[1][1], @color, @layer)
		  end
		end
	  end
	  
	end

	#this gem was made for making video games, is a subset of window
	class Game < Gosu::Window	  
	  def initialize
		super(Width, Height, Fullscreen)
		@tree = Tree.new(self, 0xFF000000, 10, Width / 2, 2)		
		self.caption = "Dell Recursion Tree"
		@text = Gosu::Font.new(self, 'comic.ttf', 10)
	  end
	  
	  def update
		@tree.update    	
	  end
	  
	  def draw
		@tree.draw		
		#my attempt at grass/sky...
		self.draw_quad(0, 0, Gosu::aqua, Width, 0, Gosu::aqua, 0, Height, Gosu::green, Width, Height, Gosu::green, 0)
		
		#instructions, need to be "drawn" since there's no text box or anything like that (that I can find) in this gem
		@text.draw("Press R to generate a random tree, or press C to customize (details below)", 10, 10, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Move mouse to the left/right for less/more branches", 10, 40, 1, 1.5, 1.5, 0xFF000000)	
		@text.draw("Press F1/F2 to decrease/increase how many levels of branches there are", 10, 50, 1, 1.5, 1.5, 0xFF000000)	
		@text.draw("Press F3/F4 to decrease/increase the size of a branch compared to its previous branch", 10, 60, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Press F5/F6 to decrease/increase the length of the trunk", 10, 70, 1, 1.5, 1.5, 0xFF000000)		
		@text.draw("F-Keys will update tree automatically, after moving the mouse press C again to update", 10, 80, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Press Esc to exit", 10, 90, 1, 1.5, 1.5, 0xFF000000)
		
		@text.draw("Warning: push buttons slowly... has a tendency to freeze", 10, 150, 1, 1.5, 1.5, 0xFF000000)
		#output the current parameters
		@text.draw("Current Tree Parameters:", 10, 300, 1, 1.5, 1.5, 0xFF000000)	
		@text.draw("Number of splits: #{$num_splits}", 10, 310, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Angle of separation: #{$angle_of_separation}", 10, 320, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Shrink range: #{$shrink_range[0]} to #{$shrink_range[$shrink_range.length-1]}", 10, 330, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Splits: #{$split_range}", 10, 340, 1, 1.5, 1.5, 0xFF000000)
		@text.draw("Trunk length: #{$trunk[0]} to #{$trunk[$trunk.length-1]}", 10, 350, 1, 1.5, 1.5, 0xFF000000)
		#sign
		@text.draw("By Nathan Dell", 10, 580, 1, 1.5, 1.5, 0xFF000000)
	  end
	  
	  #all the instructions for pressing different buttons
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
		 #F1/F2 are split range
		 if button_down? Gosu::KbF2
			$split_range = $split_range + 1
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF1
			$split_range = $split_range - 1
			@tree.custom_tree
		 end
		 #F3/F4 are shrink range
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
		 #F5/F6 are trunk size
		 if button_down? Gosu::KbF5
			trunk_start = $trunk[0] - 10
			$trunk.clear
			$trunk[0] = trunk_start
			$trunk[1] = trunk_start
			@tree.custom_tree
		 end
		 if button_down? Gosu::KbF6
			trunk_start = $trunk[0] + 10
			$trunk.clear
			$trunk[0] = trunk_start
			$trunk[1] = trunk_start
			@tree.custom_tree
		 end
	   end
	  
	end

Game.new.show
end