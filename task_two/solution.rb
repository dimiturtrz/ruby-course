def destination(snake_head, direction)
  [snake_head[0] + direction[0], snake_head[1] + direction[1]]
end

def move(snake, direction)
  snake.drop(1).push(destination(snake.last, direction))
end

def grow(snake, direction)
  snake + [destination(snake.last, direction)]
end

def new_food(food, snake, dimensions)
  new_food = [rand(dimensions[:width]), rand(dimensions[:height])]
  new_food = [rand(dimensions[:width]), rand(dimensions[:height])] while
    snake.include?(new_food) || food.include?(new_food)
  new_food
end

def obstacle_ahead?(snake, direction, dimensions)
  next_head = destination(snake.last, direction)
  no_overlap = move(snake, direction).uniq.length == snake.length
  !(next_head.first.between?(0, dimensions[:width] - 1) &&
    next_head.last.between?(0, dimensions[:height] - 1) && no_overlap)
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) ||
   obstacle_ahead?(move(snake, direction), direction, dimensions)
end
