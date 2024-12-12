#!/usr/bin/env lua

-- A Lua table playing the role of an Enum :)

Direction = {
   NONE = 0,
   NORTH = 1,
   NORTHWEST = 2,
   NORTHEAST = 3,
   SOUTH = 4,
   SOUTHWEST = 5,
   SOUTHEAST = 6,
   EAST = 7,
   WEST = 8,
}

function main()
   -- SETUP! --
   local input_file = io.open(arg[1], "r")
   local ceres_puzzle = {}

   -- Read our input file and store the lines in a list.
   for line in input_file:lines() do
      table.insert(ceres_puzzle, line)
   end

   local letter_locs = init_letter_locations(ceres_puzzle)

   -- for k, v in pairs(letter_locs) do
   --    print(k)
   --    for l = 1, #v do
   --       print(v[l][1], v[l][2])
   --    end
   --    print("")
   -- end

   -- PART ONE! --
   local result1 = calculate_xmas_count(letter_locs)
   print("PART ONE: ", result1)
end

-- HELPER FUNCTIONS! --

function init_letter_locations(input_puzzle)
   -- Dictionary that will contain the locations of each letter.
   local letter_locs = {
      X = {},
      M = {},
      A = {},
      S = {}
   }

   for i = 1, #input_puzzle do
      local line = input_puzzle[i]

      for j = 1, #line do
         -- Yes, that's how we get one character at a time in Lua :)
         local ch = line:sub(j,j)
         table.insert(letter_locs[ch], {i, j})
      end
   end

   return letter_locs
end

function calculate_xmas_count(letter_locs)
   local result = 0
   local xs = letter_locs.X
   local ms = letter_locs.M

   for i = 1, #xs do
      local next_x = xs[i]

      for j = 1, #ms do
         local next_m = ms[j]
         local direction = get_adjacency_direction(next_x, next_m)

         -- This 'X' and 'M' are adjacent, so we have a potential 'XMAS' match.
         if direction ~= Direction.NONE then
            was_match = is_xmas_match(letter_locs, next_m, 'A', direction)
            if was_match then result = result + 1 end
         end
      end
   end

   return result
end

function is_xmas_match(letter_locs, curr_letter_loc, next_letter, word_direction)
   local next_letter_locs = {}

   -- We can be recursing on an 'A' or an 'S', so fetch the corresponding locations.

   if next_letter == 'A' then
      next_letter_locs = letter_locs.A
   elseif next_letter == 'S' then
      next_letter_locs = letter_locs.S
   end

   for k = 1, #next_letter_locs do
      local next_letter_loc = next_letter_locs[k]
      local letters_direction = get_adjacency_direction(curr_letter_loc, next_letter_loc)

      -- If we found a matching letter, then there are two possibilities:
      -- If it's an 'A', then we now have to recurse to search for the 'S'.
      -- If it's an 'S', then we've found a match and can just return true.

      if letters_direction == word_direction then
         return next_letter == 'S'
            and true
            or is_xmas_match(letter_locs, next_letter_loc, 'S', word_direction)
      end
   end

   return false
end

function get_adjacency_direction(pt_a, pt_b)
   -- First, we check the 2D directions, as those have more than one condition
   -- to fulfill.

   if (pt_a[1] - pt_b[1] == 1) and (pt_a[2] - pt_b[2] == 1) then
      return Direction.NORTHWEST
   end

   if (pt_a[1] - pt_b[1] == 1) and (pt_a[2] - pt_b[2] == -1) then
      return Direction.NORTHEAST
   end

   if (pt_a[1] - pt_b[1] == -1) and (pt_a[2] - pt_b[2] == 1) then
      return Direction.SOUTHWEST
   end

   if (pt_a[1] - pt_b[1] == -1) and (pt_a[2] - pt_b[2] == -1) then
      return Direction.SOUTHEAST
   end

   -- Now, we check the 1D directions.

   if pt_a[1] - pt_b[1] == 1 then return Direction.NORTH end
   if pt_a[1] - pt_b[1] == -1 then return Direction.SOUTH end
   if pt_a[2] - pt_b[2] == 1 then return Direction.WEST end
   if pt_a[2] - pt_b[2] == -1 then return Direction.EAST end

   -- If we get here, then those two points are not adjacent to each other in
   -- any direction.
   return Direction.NONE
end

main()
