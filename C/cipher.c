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

int main() {
    uint8_t key[16] = {0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c};

    uint8_t input[4][4] = {{0x32, 0x88, 0x31, 0xe0},{ 0x43, 0x5a, 0x31, 0x37}, {0xf6, 0x30, 0x98, 0x07}, {0xa8, 0x8d, 0xa2, 0x34}};

    uint8_t output[4][4];

    
    cipher(input, key, output);

    print_state(output);
    return 0;
}