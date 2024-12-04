#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 4000

typedef enum mul_inst_status {
    ENABLED,
    DISABLED
} mul_inst_status_t;

long extract_from_corruption(char *);
long extract_from_corruption_do_dont(char *, mul_inst_status_t *);
long extract_mul_data(char *, int *, size_t);

void apply_inst_switch(char *, int *, mul_inst_status_t *);
bool is_do_inst(char *, int *);
bool is_dont_inst(char *, int *);

int main(int argc, char **argv) {
    FILE *fptr = fopen(*(argv + 1), "r");
    char line[MAX_LINE_LENGTH];

    long result1 = 0L;
    long result2 = 0L;

    /* We should actually check that fopen() did its job correctly but we'll let
       it slide today :) */

    /* Part One! */
    while (fgets(line, MAX_LINE_LENGTH, fptr) != NULL) {
        result1 += extract_from_corruption(line);
    }

    /* Part Two! */
    mul_inst_status_t status = ENABLED;
    rewind(fptr);

    while (fgets(line, MAX_LINE_LENGTH, fptr) != NULL) {
        result2 += extract_from_corruption_do_dont(line, &status);
    }

    printf("PART ONE: %ld\n", result1);
    printf("PART TWO: %ld\n", result2);

    fclose(fptr);
    return 0;
}

long extract_from_corruption(char *prog_line) {
    long result = 0L;
    size_t line_length = strlen(prog_line);

    for (int i = 0; i < line_length - 7; i++) {
        /* If it's not an 'm', then we can be sure it's part of the corrupted symbols. */
        if (*(prog_line + i) != 'm')
            continue;

        /* Let's see if it's a valid mul() operation, and add its result if it is. */
        long potential_next = extract_mul_data(prog_line, &i, line_length);

        if (potential_next >= 0)
            result += potential_next;
    }

    return result;
}

long extract_from_corruption_do_dont(char *prog_line, mul_inst_status_t *status) {
    long result = 0L;
    size_t line_length = strlen(prog_line);

    for (int i = 0; i < line_length - 7; i++) {
        /* An 'm' means a potential mul() instruction, and a 'd' means a potential
           enable/disable instruction. Any other symbol, we can be sure it's part
           of the corrupted symbols. */

        switch (*(prog_line + i)) {
        case 'd':
            apply_inst_switch(prog_line, &i, status);
            break;

        case 'm':
            /* We found a potential mul() instruction but they are disabled, so
               we just skip it. */
            if (*status == DISABLED)
                continue;

            // printf("%d\n", i);
            long potential_next = extract_mul_data(prog_line, &i, line_length);

            if (potential_next >= 0)
                result += potential_next;
            break;

        default:
            continue;
        }
    }

    return result;
}

long extract_mul_data(char *prog_line, int *index, size_t line_length) {
    /* The simplest correct mul instruction has 8 characters: mul(1,1).
       So, if we have any less than that amount, it is not possible to have any valid
       data remaining, so we just return the -1. */
    if (*index + 8 > line_length)
        return -1L;

    int mul_index = *index;
    int start_offset = 4;

    /* If the next four letters don't complete the 'mul(' spelling, then it's not
       a valid instruction we're looking for. */
    if (*(prog_line + mul_index + 1) != 'u'
        || *(prog_line + mul_index + 2) != 'l'
        || *(prog_line + mul_index + 3) != '(')
        return -1L;

    /* We need to keep track of the beginning of the potential operand to extract
       and convert it from string to number if it's valid. */
    int offset = start_offset;
    char nextch;

    while (isdigit(nextch = *(prog_line + mul_index + offset)))
        offset++;

    if (offset == start_offset || nextch != ',') {
        *index += offset;
        return -1L;
    }

    /* Build the first operand's string. */
    size_t num1_length = offset - start_offset;
    char num1_str[num1_length];
    strncpy(&num1_str[0], prog_line + mul_index + start_offset, num1_length);
    num1_str[num1_length] = '\0';

    /* Update the offsets to the second operand's position. */
    start_offset = offset + 1;
    offset = start_offset;

    while (isdigit(nextch = *(prog_line + mul_index + offset)))
        offset++;

    if (offset == start_offset || nextch != ')') {
        *index += offset;
        return -1L;
    }

    /* Build the second operand's string. */
    size_t num2_length = offset - start_offset;
    char num2_str[num2_length];
    strncpy(&num2_str[0], prog_line + mul_index + start_offset, num2_length);
    num2_str[num2_length] = '\0';

    /* Convert to numbers and return their product! Also, update the initial iterator
       index to after this mul() operation. */

    long num1 = strtol(num1_str, NULL, 10);
    long num2 = strtol(num2_str, NULL, 10);

    *index += offset;
    return num1 * num2;
}

void apply_inst_switch(char *prog_line,
                       int *index,
                       mul_inst_status_t *status)
{
    /* Move to the next letter after the 'd' that led us here. */
    *index += 1;

    /* If the next letter is not an 'o', then it doesn't say "do" or "don't". */
    if (*(prog_line + *index) != 'o')
        return ;

    *index += 1;

    /* Might be a do() instruction. */
    if (*(prog_line + *index) == '(') {
        /* do() does not receive any arguments, so if it's not a ')', then it
           turned out to be part of the corrupted symbols. */
        if (*(prog_line + *index + 1) != ')')
            return ;

        *status = ENABLED;
    }

    /* Might be a don't() instruction. */
    else if (*(prog_line + *index) == 'n') {
        /* We have to check character by character to know whether it really is
           a don't() instruction, or part of the corrupted symbols. */
        if (*(prog_line + *index + 1) != '\'')
            return ;

        *index += 1;
        if (*(prog_line + *index + 1) != 't')
            return ;

        *index += 1;
        if (*(prog_line + *index + 1) != '(')
            return ;

        *index += 1;
        if (*(prog_line + *index + 1) != ')')
            return ;

        *status = DISABLED;
    }

    /* Else it was actually not a flip instruction, so we don't do anything. */
}
