#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "Aes.h"
#include <string.h>

void cipher(uint8_t input[4][4], uint8_t key[16], uint8_t output[4][4]) {
    uint8_t State[4][4];

    memcpy(State, input, 16*sizeof(uint8_t));
    
    
    uint8_t key_schedule[44][4];

    keyExp(key, key_schedule);

    AddRoundKey(State, key_schedule, 0);

    for (int round = 1; round < 10; round++) {
        sub_bytes(State);
        shift_rows(State);
        mix_columns(State);
        AddRoundKey(State, key_schedule, round);
    }
    sub_bytes(State);
    shift_rows(State);
    AddRoundKey(State, key_schedule, 10);

    memcpy(output, State, 16*sizeof(uint8_t));

}

