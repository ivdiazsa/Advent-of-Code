#!/usr/bin/env python3

from enum import Enum
import sys

class Operation(Enum):
    NONE = 0
    INCREASE = 1
    DECREASE = 2

# HELPER FUNCTIONS!

def is_safe(report: list[int]) -> bool:
    # If safe reports must be an increasing or decreasing series, then by definition
    # we can't have repeated numbers. Also, no need to even start processing the list
    # if our first two numbers differ by more than 3 units.
    if len(report) != len(set(report)) or abs(report[0] - report[1]) > 3:
        return False

    series_op = Operation.NONE

    if report[0] < report[1]:
        series_op = Operation.INCREASE
    else:
        series_op = Operation.DECREASE

    for i in range(1, len(report) - 1):
        diff = report[i] - report[i + 1]

        if abs(diff) > 3 \
           or (diff > 0 and series_op == Operation.INCREASE) \
           or (diff < 0 and series_op == Operation.DECREASE):
            return False

    return True


def is_safe_dampened_naive(report: list[int]) -> bool:
    if is_safe(report):
        return True

    for i in range(0, len(report)):
        if is_safe(report[0:i] + report[i+1:]):
            return True

    return False


# MAIN SCRIPT SETUP!

input_file = sys.argv[1]
reports_list = []

with open(input_file, 'r') as reports_file:
    for line in reports_file:
        reports_list.append(list(map(int, line.split(' '))))

# MAIN SCRIPT PART ONE!

safe_count = 0

for report in reports_list:
    if is_safe(report):
        safe_count += 1

print(f"PART ONE: {safe_count}")

# MAIN SCRIPT PART TWO!

safe_count = 0

for report in reports_list:
    if is_safe_dampened_naive(report):
        safe_count += 1

print(f"PART TWO: {safe_count}")


# DRAFTS AND STUFF

# def is_safe_dampened(report: list[int]) -> bool:
#     if is_safe(report):
#         return True

#     # Cases to consider:
#     # 1) First element is faulty but the rest are good.
#     # 2) Second element indicates an operation but the rest indicate the other.
#     # 3) An element exceeds the limit of 3-diff.
#     # 4) An element is equal to another.
#     # 5) We can fix stuff either by hopping to the +2 element, or use +1 and +2.

#     series_op = Operation.NONE
#     has_forgiven = False


# # HELPERS FOR IS_SAFE_DAMPENED!

# def is_faulty_first(report: list[int]) -> bool:
#     int first = report[0]
#     int second = report[1]
#     return first != second and abs(first - second) <= 3


# def is_safe_dampened_first_draft(report: list[int]) -> bool:
#     series_op = Operation.NONE
#     has_forgiven = False

#     for i in range(0, len(report) - 1):
#         diff = report[i] - report[i + 1]

#         if abs(diff) > 3:
#             # We've already removed one item to make it safe, so another faulty one
#             # means this sequence is not safe.
#             if has_forgiven:
#                 return False

#             # Only the last number yields a bigger difference, so we can remove it
#             # and consider this a safe sequence.
#             if i == len(report) - 2:
#                 return True

#             diff_1_3 = report[i] - report[i + 2]

#             if series_op == Operation.NONE and diff_1_3 > 0 and abs(diff_1_3) <= 3:
#                 series_op = Operation.DECREASE
#             elif series_op == Operation.NONE and diff_1_3 < 0 and abs(diff_1_3) <= 3:
#                 series_op = Operation.INCREASE

#             if series_op == Operation.NONE or abs(diff_1_3) > 3 or abs(diff_1_3) == 0:
#                 diff_2_3 = report[i + 1] - report[i + 2]

#                 if series_op == Operation.NONE and diff_2_3 > 0 and abs(diff_2_3) <= 3:
#                     series_op = Operation.DECREASE
#                 elif series_op == Operation.NONE and diff_2_3 < 0 and abs(diff_2_3) <= 3:
#                     series_op = Operation.INCREASE

#                 if series_op == Operation.NONE or abs(diff_2_3) > 3 or abs(diff_2_3) == 0:
#                     return False

#                 if (diff_2_3 > 0 and series_op == Operation.INCREASE) \
#                    or (diff_2_3 < 0 and series_op == Operation.DECREASE):
#                     return False

#                 i += 1
#                 has_forgiven = True
#                 continue

#             if (diff_1_3 > 0 and series_op == Operation.INCREASE) \
#                or (diff_1_3 < 0 and series_op == Operation.DECREASE):
#                 return False

#             i += 2
#             has_forgiven = True
#             continue

#         if diff == 0:
#             if has_forgiven:
#                 return False

#             if i == len(report) - 2:
#                 return True

#             diff_1_3 = report[i] - report[i + 2]

#             if series_op == Operation.NONE and diff_1_3 > 0 and abs(diff_1_3) <= 3:
#                 series_op = Operation.DECREASE
#             elif series_op == Operation.NONE and diff_1_3 < 0 and abs(diff_1_3) <= 3:
#                 series_op = Operation.INCREASE

#             if series_op == Operation.NONE or abs(diff_1_3) > 3 or abs(diff_1_3) == 0:
#                 diff_2_3 = report[i + 1] - report[i + 2]

#                 if series_op == Operation.NONE and diff_2_3 > 0 and abs(diff_2_3) <= 3:
#                     series_op = Operation.DECREASE
#                 elif series_op == Operation.NONE and diff_2_3 < 0 and abs(diff_2_3) <= 3:
#                     series_op = Operation.INCREASE

#                 if series_op == Operation.NONE or abs(diff_2_3) > 3 or abs(diff_2_3) == 0:
#                     return False

#                 if (diff_2_3 > 0 and series_op == Operation.INCREASE) \
#                    or (diff_2_3 < 0 and series_op == Operation.DECREASE):
#                     return False

#                 i += 1
#                 has_forgiven = True
#                 continue

#             if (diff_1_3 > 0 and series_op == Operation.INCREASE) \
#                or (diff_1_3 < 0 and series_op == Operation.DECREASE):
#                 return False

#             i += 2
#             has_forgiven = True
#             continue

#         if i == len(report) - 2:
#             return True

#         if series_op == Operation.NONE and diff > 0 and abs(diff) <= 3:
#             series_op = Operation.DECREASE
#         elif series_op == Operation.NONE and diff < 0 and abs(diff) <= 3:
#             series_op = Operation.INCREASE

#     return True
