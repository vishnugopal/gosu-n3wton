require 'rubygems'
require 'gosu'


class Bullet
  
  def initialize(tank, options={})
    window = tank.window
    @image = Gosu::Image.new(window, options['image'], false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end
  
  def attributes
    { :x => @x, :y => @y, :vel_x => @vel_x, 
      :vel_y => @vel_y, :angle => @angle  }
  end
  
  def place(x, y)
    @x, @y = x, y
  end
  
  #has the bullet hit a tank?
  def hit?(tank)
    Gosu::distance(@x, @y, tank.position[:x], tank.position[:y]) < tank.size
  end
  
  #move bullet out of screen
  def destroy
    @x = @y = 1000
  end
  
  #is the bullet out of the screen?
  def spent?
    (@x < 0 or @x > 640) or (@y < 0 or @y > 480)
  end
  
  def shoot(angle, thrust)
    unless @shot
      @shot = true
      @angle = angle
      @vel_x += Gosu::offset_x(@angle, thrust)
      @vel_y += Gosu::offset_y(@angle, thrust)
    end
  end
  
  def move
    @x += @vel_x unless spent?
    @y += @vel_y unless spent?
  end
  
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end

