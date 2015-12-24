class TurtleGraphics
  DIRECTIONS = [[0, -1], [1, 0], [0, 1], [-1, 0]]
  class Turtle
    def initialize x, y
      @width = x
      @height = y
      @canvas = Array.new(y) { Array.new(x, 0) }
      @canvas[0][0] = 1
      @turtle = [0,0]
      look :right
    end

    def draw(special_canvas = false, &block)
      instance_eval &block
      return special_canvas.transform @canvas if special_canvas
      @canvas
    end

    def look(orientation)
      @direction = case orientation
        when :left then DIRECTIONS[0]
        when :down then DIRECTIONS[1]
        when :right then DIRECTIONS[2]
        when :up then DIRECTIONS[3]
      end
    end

    def move
      @turtle[0] = (@turtle[0] + @direction.first) % @height
      @turtle[1] = (@turtle[1] + @direction.last) % @width
      @canvas[@turtle.first][@turtle.last] += 1
    end

    def turn_right
      @direction = DIRECTIONS[(DIRECTIONS.index(@direction) - 1) % 4]
    end

    def turn_left
      @direction = DIRECTIONS[(DIRECTIONS.index(@direction) + 1) % 4]
    end

    def spawn_at(row, column)
      @turtle[0] = row
      @turtle[1] = column
    end
  end

  class Canvas
    class ASCII
      def initialize(intensities)
        @intensities = intensities
      end

      def transform(canvas)
        max_value = canvas.map(&:max).max
        intensity_step = max_value.to_f / (@intensities.size - 1)
        canvas.map do |row|
          row.map{ |value| @intensities[value.to_f / intensity_step] } << "\n"
        end.join ""
      end
    end

    class HTML
      def initialize(square_edge)
        @square_edge = square_edge
      end

      def get_table canvas, max_value
        table = ""
        canvas.map do |row|
          table << "\t<tr>\n"
          row.map do |value|
            opacity = format('%.2f', value.to_f / max_value)
            table << "\t\t<td style=\"opacity: #{opacity}\"></td>\n"
          end
          table << "\t</tr>\n"
        end
        table
      end

      def transform(canvas)
        max_value = canvas.map(&:max).max
        table = get_table canvas, max_value
        <<-EOS
<!DOCTYPE html>
<html>
<head>
\t<title>Turtle graphics</title>

\t<style>
\t\ttable {
\t\t\tborder-spacing: 0;
\t\t}

\t\ttr {
\t\t\tpadding: 0;
\t\t}

\t\ttd {
\t\t\twidth: #{@square_edge}px;
\t\t\theight: #{@square_edge}px;

\t\t\tbackground-color: black;
\t\t\tpadding: 0;
\t\t}
\t</style>
</head>
<body>
\t<table>
#{table}
\t</table>
</body>
</html>
          EOS
      end
    end
  end
end
