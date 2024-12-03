#!/usr/bin/env python3

from enum import Enum
import sys

class Operation(Enum):
    INCREASE = 1
    DECREASE = 2

# HELPER FUNCTIONS!

def is_safe(report: list[int]) -> bool:
    # If safe reports must be an increasing or decreasing series, then by definition
    # we can't have repeated numbers. Also, no need to even start processing the list
    # if our first two numbers differ by more than 3 units.
    if len(report) != len(set(report)) or abs(report[0] - report[1]) > 3:
        return False

    series_op = None
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


def is_safe_dampened(report: list[int]) -> bool:
    if is_safe(report):
        return True

    return True


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
    if is_safe_dampened(report):
        safe_count += 1

print(f"PART TWO: {safe_count}")
