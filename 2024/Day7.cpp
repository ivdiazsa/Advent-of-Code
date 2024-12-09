#include <iostream>
#include <format>
#include <fstream>
#include <string>
#include <vector>

#include <boost/algorithm/string.hpp>

bool is_equation_fixable(long,
                         long,
                         std::vector<long>::const_iterator,
                         std::vector<long>::const_iterator,
                         bool);

long concat_digits(long, long);

int main(int argc, char *argv[])
{
    /* SETUP! */

    std::ifstream inputFile(argv[1]);
    std::string inputLine;

    std::vector<std::vector<long>> equations;

    // Read and parse our puzzle input.

    while (getline(inputFile, inputLine))
    {
        // Index 0 contains the needed result, and indexes 1 and on contain the
        // operands that ought to be used to get said result in the equation.

        std::vector<std::string> tokens;
        std::vector<long> eq;
        boost::split(tokens, inputLine, boost::is_any_of(" "));

        for (auto it = tokens.cbegin(); it != tokens.cend(); it++)
        {
            long value = std::stol(*it);
            eq.push_back(value);
        }
        equations.push_back(eq);
    }

    long long result1 = 0;
    long long result2 = 0;

    for (auto it = equations.cbegin(); it != equations.cend(); it++)
    {
        // Check each equation, and if it's possible to make it true, then add
        // its result to the puzzle's result. For our recursive helper, it's best
        // to have the operands separate from the result. Also, let me be funny
        // and use iterators here instead of indexes :)

        std::vector<long>::const_iterator equationIter = (*it).cbegin();
        long equationResult = *equationIter;
        ++equationIter; // Now points at the first operand.

        bool isPartOneFixable = is_equation_fixable(equationResult,
                                                    *equationIter,
                                                    equationIter + 1,
                                                    (*it).cend(),
                                                    false);

        bool isPartTwoFixable = is_equation_fixable(equationResult,
                                                    *equationIter,
                                                    equationIter + 1,
                                                    (*it).cend(),
                                                    true);

        if (isPartOneFixable)
            result1 += equationResult;

        if (isPartTwoFixable)
            result2 += equationResult;
    }

    std::cout << std::format("PART ONE: {}", result1) << std::endl;
    std::cout << std::format("PART TWO: {}", result2) << std::endl;
    return 0;
}

/* HELPER FUNCTIONS! */

bool is_equation_fixable(long expected,
                         long cumulativeResult,
                         std::vector<long>::const_iterator operandsIter,
                         std::vector<long>::const_iterator eqEndIter,
                         bool isConcatEnabled)
{
    // If we've reached the end of the equation, then we just have to check whether
    // our result matches the expected one. If yes, we've found a solution to the
    // equation signs. If not, well then no :)

    if (operandsIter == eqEndIter)
        return cumulativeResult == expected;

    long sumResult = cumulativeResult + *operandsIter;
    long prodResult = cumulativeResult * *operandsIter;

    // Check the sum and product branches recursively to know if at least one takes
    // us to the equation's result.

    bool isSumBranchFixable = is_equation_fixable(expected,
                                                  sumResult,
                                                  operandsIter + 1,
                                                  eqEndIter,
                                                  isConcatEnabled);

    bool isProdBranchFixable = is_equation_fixable(expected,
                                                   prodResult,
                                                   operandsIter + 1,
                                                   eqEndIter,
                                                   isConcatEnabled);

    if (isConcatEnabled)
    {
        long concatResult = concat_digits(cumulativeResult, *operandsIter);

        bool isConcatBranchFixable = is_equation_fixable(expected,
                                                         concatResult,
                                                         operandsIter + 1,
                                                         eqEndIter,
                                                         isConcatEnabled);

        return isSumBranchFixable || isProdBranchFixable || isConcatBranchFixable;
    }

    return isSumBranchFixable || isProdBranchFixable;
}

long concat_digits(long num1, long num2)
{
    std::string pastedNums = std::format("{}{}", num1, num2);
    return std::stol(pastedNums);
}
