require 'gosu'

class Drawable

    attr_accessor :x, :y, :width, :height, :velocity_x, :velocity_y, :visible
    def initialize(image_location, x, y)
        @image = Gosu::Image.new(image_location)
        @x = x
        @y = y
        @width = 300
        @height = 300
        @offset = 1
        @velocity_x = rand(7) + @offset
        @velocity_y = rand(7) + @offset
        @visible = 0
    end

    def image
        return @image
    end

    def reset
        # Reset AND get faster!
        @offset += 1
        @velocity_x = rand(9) + @offset
        @velocity_y = rand(9) + @offset
    end

end

class WhackARubby < Gosu::Window

    def initialize
        super(800,600)
        self.caption = "Whack the Rubby!"
        @ruby = Drawable.new('images/ruby.png', 200, 200)
        @kitten = Drawable.new('images/kitten.png', 150, 150)
        @kitten_alive = true
        @drawables = [@ruby, @kitten]
        @hammer_image = Gosu::Image.new('images/hammer.png')

        @hit = 0
        @font = Gosu::Font.new(30)
        @score = 0
        @playing = true
        @start_time = 0
        @high_score = 0
    end

    def draw
        @font.draw("High Score: #{@high_score}", 300, 550, 3)
        @drawables.each do |d|
            if d.visible > 0
                d.image.draw(d.x - d.width/2, d.y - d.height/2, 1)
            end
        end
        @hammer_image.draw(mouse_x - 150, mouse_y - 150, 1)
        if @hit == 0
            color = Gosu::Color::NONE
        elsif @hit == 1
            color = Gosu::Color::GREEN
        elsif @hit == -1
            color = Gosu::Color::RED
        end
        draw_quad(0, 0, color, 800, 0, color, 800, 600, color, 0, 600, color)
        @hit = 0
        @font.draw(@score.to_s, 700, 20, 2)
        @font.draw(@time_left.to_s, 20, 20, 2)
        if not @playing
            if not @kitten_alive
                @font.draw("No! You leave that kitten alone!", 200, 100, 3)
            end
            @font.draw('Game Over!', 300, 300, 3)
            @font.draw('Press space to play again', 200, 325, 3)
            if @score > @high_score
                @high_score = @score
            end
            @visible = 20
        end
    end

    def update
        if @playing
            @drawables.each do |d|
                d.x += d.velocity_x
                d.y += d.velocity_y
                d.velocity_x *= -1 if d.x + d.width/2 > 800 || d.x - d.width/2 < 0
                d.velocity_y *= -1 if d.y + d.height/2 > 600 || d.y - d.height/2 < 0
                d.visible -= 1
                d.visible = 50 if d.visible < -10 && rand < 0.01
            end
            @time_left = (30 - ((Gosu.milliseconds - @start_time) / 1000))
            if @time_left < 0
                @time_left = 0
                @playing = false
            end
        end
    end

    def button_down(id)
        if @playing
            if (id == Gosu::MsLeft)
                if Gosu.distance(mouse_x - 150, mouse_y - 30, @ruby.x, @ruby.y) < 130 && @ruby.visible >= 0
                    @hit = 1
                    @score += 5
                else
                    @hit = -1
                    @score -= 1
                end
                if Gosu.distance(mouse_x - 150, mouse_y - 30, @kitten.x, @kitten.y) < 100 && @kitten.visible >= 0
                    @playing = false
                    @score -= 50
                    @kitten_alive = false
                end
            end
        else
            if (id == Gosu::KbSpace)
                @playing = true
                @ruby.visible = -10
                @start_time = Gosu.milliseconds
                @score = 0
                @drawables.each do |d|
                    d.reset
                end
            end
        end
    end

end

window = WhackARubby.new
window.show
