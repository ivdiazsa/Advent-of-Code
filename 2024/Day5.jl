#!/usr/bin/env julia

function main()
    page_rules = Dict{Int, Vector{Int}}()
    update_pages = Vector{Vector{Int}}()
    input_section::Int = 1

    # SETUP! Reading and parsing the puzzle input file.

    for line in eachline(ARGS[1])
        # If we find an empty line that is not EOF, then that means we're done
        # reading the page rules, and will now start reading the puzzle input.
        if length(line) == 0
            input_section = 2
            continue
        end

        if input_section == 1
            # Parse the next page rule, which comes in format "x|y", meaning
            # that 'x' should come before 'y' in the puzzle input.
            before, after = map(x -> parse(Int, x), split(line, '|'))

            # Append 'x' to the list of numbers that should come before 'y'.
            if !haskey(page_rules, after)
                page_rules[after] = Vector{Int}()
            end
            append!(page_rules[after], before)

        elseif input_section == 2
            # Parse the next puzzle input, which comes in a comma-separated fashion,
            # and add it to our puzzles list.
            next_update = map(x -> parse(Int, x), split(line, ','))
            push!(update_pages, next_update)
        end
    end

    result1, result2 = sum_of_middles(update_pages, page_rules)

    println("PART ONE: $(result1)")
    println("PART TWO: $(result2)")
end

# HELPER FUNCTIONS!

function sum_of_middles(updates::Vector{Vector{Int}},
                        rules::Dict{Int, Vector{Int}})
    corrects_sum::Int = 0
    fixeds_sum::Int = 0

    # Check all of our updates:
    # - Add the middle pages of the valid ones into the 'corrects_sum' var.
    # - Fix the incorrect ones, and add their new middle pages to the 'fixeds_sum' var.

    for u in updates
        was_valid, middle_page = fix_or_apply(u, rules)
        was_valid ? corrects_sum += middle_page : fixeds_sum += middle_page
    end

    return corrects_sum, fixeds_sum
end

function fix_or_apply(update::Vector{Int}, rules::Dict{Int, Vector{Int}})
    valid::Bool = true
    middle::Int = -1

    # For rearranging the incorrect updates, we'll be using a modified version of
    # the Bubble Sort algorithm. However, the swaps have to be done in a specific
    # order to reach the right answer. So, we'll be using a little list to keep
    # track of the pairs of elements we will have to swap.
    swaps = Vector{Tuple{Int, Int}}()

    # Check if all the page numbers in this update follow the rules, and fix those
    # that don't.
    for i in range(1, length(update) - 1)
        curr_page = update[i]
        page_rules = get(rules, curr_page, nothing)

        # If there are no rules for this number, then it means that there are
        # no numbers specified that should go before this one, so no need to
        # check the later ones.
        page_rules == nothing && continue

        # If any element after our current one appears in its rules list of those
        # that should go before, then add that pair to the list of "bubble swaps"
        # we have to perform.
        for j in range(i + 1, length(update))
            next_page = update[j]
            any(x -> x == next_page, page_rules) && push!(swaps, (curr_page, next_page))
        end
    end

    if length(swaps) > 0
        valid = false
        elves_bubble_sort!(update, swaps)

        # We should have fixed it entirely by now, but there were one or more cases
        # that required another pass :/
        fix_or_apply(update, rules)
    end

    middle = update[ceil(Int, length(update) / 2)]
    return valid, middle
end

function elves_bubble_sort!(update::Vector{Int}, swaps::Vector{Tuple{Int, Int}})
    # We'll be using a little dictionary to keep track of each element's position,
    # for efficiency's sake. This way, we won't have to iterate the entire update
    # vector to find the target for each swap.

    indexes = Dict{Int, Int}()
    for i in range(1, length(update))
        indexes[update[i]] = i
    end

    for sw in swaps
        indx1 = indexes[sw[1]]
        indx2 = indexes[sw[2]]
        update[indx1], update[indx2] = update[indx2], update[indx1]

        # Update our dictionary of indexes after the swap.
        indexes[sw[1]] = indx2
        indexes[sw[2]] = indx1
    end
end

main()
