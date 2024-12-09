#!/usr/bin/env ruby

require 'set'

def main(args)
  input_file = args[0]

  # SETUP!

  lab_grid = File.readlines(input_file, chomp: true)

  ### PART ONE ###

  start_point = find_start_point(lab_grid)
  guard_trail = test_guard_path(lab_grid, start_point)

  trail_points = Set.new
  guard_trail.each { |pt| trail_points << pt[0] }

  puts "PART ONE: #{trail_points.size}"

  ### PART TWO ###

  # To figure out the spaces where adding obstacles would get the guard stuck in
  # a loop, we will leverage the results of Part One. After all, placing an obstacle
  # where the guard won't pass in the first place wouldn't be very useful.

  # First, delete the origin point. The guard is already standing there, so they
  # would notice right away if we tried to add a new obstacle there.

  trail_points.delete(start_point)
  successful_obstacles = 0

  trail_points.each do |space|
    # Temporarily add an obstacle in each space the guard walks through and test
    # whether it is now a loop.

    obstacle_x, obstacle_y = space[0], space[1]
    lab_grid[obstacle_x][obstacle_y] = '#'
    successful_obstacles += 1 unless test_guard_path(lab_grid, start_point)

    # Restore the empty space for the next test.
    lab_grid[obstacle_x][obstacle_y] = '.'
  end

  puts "PART TWO: #{successful_obstacles}"
end

# HELPER FUNCTIONS!

def test_guard_path(lab_grid, start_point)
  guard_pt = start_point
  curr_direction = "NORTH"
  spaces_visited = Set.new

  # Making a pseudo-enum of the 4 different directions here :)
  directions = {
    "NORTH" => [-1, 0],
    "EAST" => [0, 1],
    "SOUTH" => [1, 0],
    "WEST" => [0, -1]
  }

  while true
    # Add this space to the list of visiteds if we haven't already.

    return nil unless spaces_visited.add?([guard_pt, curr_direction])

    # Test if the next point is the guard's way out.

    next_pt = add_points(guard_pt, directions[curr_direction])
    unless is_in_grid(next_pt, lab_grid) then break end

    # If not, then test if it is an obstacle. If yes, then change to the next
    # direction. If not, then step forward.

    if lab_grid[next_pt[0]][next_pt[1]] == '#'
      curr_direction = next_direction(curr_direction)
    else
      guard_pt = next_pt
    end
  end

  return spaces_visited
end

def find_start_point(grid)
  for i in (0...grid.length)
    row = grid[i]
    for j in (0...row.length)
      return [i, j] if row[j] == '^'
    end
  end
end

def add_points(point_a, point_b)
  [point_a[0] + point_b[0], point_a[1] + point_b[1]]
end

def is_in_grid(point, grid)
  (point[0] >= 0 and point[0] < grid.length) and
    (point[1] >= 0 and point[1] < grid[0].length)
end

def next_direction(current)
  nextd = ""

  case current
  when "NORTH" then nextd = "EAST"
  when "EAST" then nextd = "SOUTH"
  when "SOUTH" then nextd = "WEST"
  when "WEST" then nextd = "NORTH"
  end

  nextd
end

main(ARGV)
