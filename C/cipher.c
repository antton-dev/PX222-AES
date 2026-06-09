#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include "Aes.h"

void aes_encrypt(state output[4][4], state input[4][4], word *key, int key_length) {
    state State[4][4];
    int Nr = 10;

    if (key_length == 4)      Nr = 10;
    else if (key_length == 6) Nr = 12;
    else if (key_length == 8) Nr = 14;
    else exit(1);

    memcpy(State, input, 16 * sizeof(uint8_t));
    uint8_t key_schedule[60][4];

    keyExp(key, key_schedule, key_length);

    AddRoundKey(State, key_schedule, 0);

    for (int round = 1; round < Nr; round++) {
        sub_bytes(State);
        shift_rows(State);
        mix_columns(State);
        AddRoundKey(State, key_schedule, round);
    }

    sub_bytes(State);
    shift_rows(State);
    AddRoundKey(State, key_schedule, Nr);

    memcpy(output, State, 16 * sizeof(uint8_t));
}