#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "Aes.h"

bool compare(uint8_t state1[4][4], uint8_t state2[4][4]) {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if (state1[i][j] != state2[i][j]) return false;
        }
    }
    return true;
}

int main() {
    // ---------------------------------------------------------
    //                     TEST 1 : MixColumns 
    // ---------------------------------------------------------
    uint8_t debut_mix[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e},
        {0xbf, 0xb4, 0x41, 0x27},
        {0x5d, 0x52, 0x11, 0x98},
        {0x30, 0xae, 0xf1, 0xe5} // 0xe5
    };

    uint8_t attendu_mix[4][4] = {
        {0x04, 0xe0, 0x48, 0x28},
        {0x66, 0xcb, 0xf8, 0x06},
        {0x81, 0x19, 0xd3, 0x26},
        {0xe5, 0x9a, 0x7a, 0x4c}
    };

    printf("Test MixColumns : ");
    mix_columns(debut_mix); 

    if (compare(debut_mix, attendu_mix)) {
        printf("True\n\n");
    } else {
        printf("False\n\n");
    }

    // ---------------------------------------------------------
    //                  TEST 2 : InvMixColumns
    // ---------------------------------------------------------
    
    uint8_t debut[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e},
        {0xbf, 0xb4, 0x41, 0x27},
        {0x5d, 0x52, 0x11, 0x98},
        {0x30, 0xae, 0xf1, 0xe5}
    };
    
    inv_mix_columns(debut_mix); 
    
    printf("Test InvMixColumns : ");

    if (compare(debut_mix, debut)) {
        printf("True\n\n");
    } else {
        printf("False\n\n");
    }

    return 0;
}