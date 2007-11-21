#
# Vishnu Gopal 
# Nov, 2007
#

require 'rubygems'
require 'yaml'
require 'gosu'

require 'tank'
require 'bullet'

class N3wton < Gosu::Window
  
  def initialize(settings={})
    super(640, 480, false)
    self.caption = "Tank Test"
    @settings = settings
    @enemy_count = settings['enemy_count']
    @enemies = []
    @enemy_count.times do
      enemy = Tank.new(self, settings['tank']['enemy'])
      @enemies.push(enemy)
      enemy.place((rand * 600) + 20, (rand * 400) + 10)
    end
    
    @player = Tank.new(self, settings['tank']['player'])
    @player.place(320, 220, 0)
  end
  
  def update
    @tanks = @enemies + [@player]
    @enemies.reject! { |enemy| enemy.dead? }
    
    if @player.dead? 
      puts "Player dead, you lose!"
      close
    end
    
    if @enemies.empty?
      puts "All enemies dead, you win!"
      close
    end

    
    @player.turn_left if button_down? Gosu::Button::KbLeft 
    @player.turn_right if button_down? Gosu::Button::KbRight
    
    @player.bullets.each do |bullet|
      @enemies.each do |enemy|
        if bullet.hit?(enemy)
          bullet.destroy
          enemy.react_to(bullet)
        end
      end
    end
    @enemies.collect { |enemy| enemy.bullets }.flatten.each do |bullet|
      if bullet.hit?(@player)
        bullet.destroy
        @player.react_to(bullet)
      end
    end
    @enemies.each { |enemy| enemy.track_and_shoot(@player) if (Gosu::milliseconds / 15 % (@settings['tank']['enemy']['bullet']['track_time']) == 0) } 
    @player.direct_motion
    @enemies.each { |enemy| enemy.direct_motion }
  end
  
  def draw
    @player.draw
    @enemies.each { |enemy| enemy.draw }
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    end
  end
  
  def button_up(id)
    if id == Gosu::Button::KbSpace
       @player.shoot if @player.bullet_ready?
    end
  end

end

settings = YAML.load(File.open("./settings.yml", "r"))
w = N3wton.new(settings)
w.show