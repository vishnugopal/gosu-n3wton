require 'rubygems'
require 'gosu'

require 'bullet'

class Tank
  
  attr_reader :bullets, :window
  
  def initialize(window, options = {})
    @window = window
    @ready_image   = Gosu::Image.new(@window, options['images']['ready'], false)
    @waiting_image = Gosu::Image.new(@window, options['images']['waiting'], false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @bullets = []
    @bullet_options = options['bullet']
    @bullet_burst = @bullet_options['burst'] || 2.5
    @has_recoil = options['has_recoil'] || false
    @tank_size = options['size'] || 10
  end
  
  def position
    { :x => @x, :y => @y }
  end
  
  def place(x, y, angle = 0)
    @x, @y, @angle = x, y, angle
  end
  
  def has_recoil?
    @has_recoil == true
  end
  
  def turn_left
    @angle -= 5
    @angle %= 360
  end
  
  def turn_right
    @angle += 5
    @angle %= 360
  end
  
  def size
    @tank_size
  end
  
  def bullet_ready?
    @bullet_ready || (@bullet_ready = (Gosu::milliseconds / 15 % @bullet_options['reload_time'] == 0))
  end
  
  def track_and_shoot(tank)
    return if (@x - tank.position[:x]) == 0
    
    offset_x_minus = @x + Gosu::offset_x(@angle - 5, 5)
    offset_y_minus = @y + Gosu::offset_y(@angle - 5, 5)
    offset_x_plus = @x + Gosu::offset_x(@angle + 5, 5)
    offset_y_plus = @y + Gosu::offset_y(@angle + 5, 5)
    a_plus  = Gosu::distance(@x, @y, offset_x_plus, offset_y_plus)
    a_minus = Gosu::distance(@x, @y, offset_x_minus, offset_y_minus)
    b_plus  = Gosu::distance(offset_x_plus, offset_y_plus, tank.position[:x], tank.position[:y])
    b_minus = Gosu::distance(offset_x_minus, offset_y_minus, tank.position[:x], tank.position[:y])
    c = Gosu::distance(@x, @y, tank.position[:x], tank.position[:y])
    
    angle_plus  = Math.acos(((a_plus ** 2) + (c ** 2) - (b_plus ** 2)) / (2 * a_plus * c))
    angle_minus = Math.acos(((a_minus ** 2) + (c ** 2) - (b_minus ** 2)) / (2 * a_minus * c))
      
    if angle_minus > angle_plus 
      turn_right
    else
      turn_left
    end
    
    shoot
  end
  
  def shoot
    return unless bullet_ready?
    @bullet_ready = false
    bullet = Bullet.new(self, @bullet_options)
    bullet.place(@x, @y)
    bullet.shoot(@angle, @bullet_burst)
    @bullets.push(bullet)
    bounce_back if has_recoil? 
  end
  
  def dead?
    @x <= 0 or @x >= 640 or @y <=0 or @y >= 480
  end
  
  def bounce_back
    @vel_x += Gosu::offset_x((180 + @angle), @bullet_burst / 10)
    @vel_y += Gosu::offset_y((180 + @angle), @bullet_burst / 10)
  end
  
  def move
    @x += @vel_x if @x < 640
    @y += @vel_y if @y < 480
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end
  
  def direct_motion()
    @bullets.each do |bullet| 
      bullet.move
      bullet.draw 
    end
    @bullets.reject! { |bullet| bullet.spent? }
    
    move
  end
  
  def react_to(bullet)
    @vel_x += (bullet.attributes[:vel_x] / 10)
    @vel_y += (bullet.attributes[:vel_y] / 10)
  end
  
  def draw
    if bullet_ready?
      image = @ready_image
    else
      image = @waiting_image
    end
    image.draw_rot(@x, @y, 1, @angle) 
  end
  
end