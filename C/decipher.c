#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "Aes.h"
#include <string.h>

void decipher(uint8_t input[4][4], uint8_t key[16], uint8_t output[4][4]) {
    uint8_t State[4][4];

    memcpy(State, input, 16*sizeof(uint8_t));
    
    
    uint8_t key_schedule[44][4];

    keyExp(key, key_schedule);

    AddRoundKey(State, key_schedule, 10);

    for (int round = 9; round >= 1; round--) {
        inv_shift_rows(State);
        inv_sub_bytes(State);
        AddRoundKey(State, key_schedule, round);
        inv_mix_columns(State);
    }
    inv_shift_rows(State);
    inv_sub_bytes(State);
    AddRoundKey(State, key_schedule, 0);

    memcpy(output, State, 16*sizeof(uint8_t));

}

