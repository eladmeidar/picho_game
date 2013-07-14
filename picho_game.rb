require 'rubygems'
require 'gosu'

module ZOrder
  Background, Stars, Player, UI = *0..3
end

class Star
  attr_reader :x, :y

  def initialize(window)
    @image = Gosu::Image.new(window, "pin.png", false)
    @x = rand * 640
    @y = rand * 480
    @angle = 0.0
  end

  def draw  
    @image.draw_rot(@x, @y, 1, @angle)
  end
end

class Player
  def initialize(window)
    @image = Gosu::Image.new(window, "picho.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end
  
  def turn_left
    @angle -= 4.5
  end
  
  def turn_right
    @angle += 4.5
  end
  
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end
  
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

   def score
    @score
  end

  def collect_stars(stars)
    if stars.reject! {|star| Gosu::distance(@x, @y, star.x, star.y) < 35 } then
      @score += 1
    end
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Ben ha picho shel ashdod"
     @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @background_image = Gosu::Image.new(self, "ashdod.png", true)
    @player = Player.new(self)
    @player.warp(320, 240)

    @stars = Array.new
  end
  
  def update
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      @player.turn_left
    end
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      @player.turn_right
    end
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    @player.move
    @player.collect_stars(@stars)

    if rand(100) < 4 and @stars.size < 10 then
      star = Star.new(self)

      @stars.push(star)

      star.draw
    end
  end
  
  def draw
    @player.draw
    @background_image.draw(0, 0, 0)
    @stars.each { |star| star.draw }
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff666600)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end

window = GameWindow.new
window.show