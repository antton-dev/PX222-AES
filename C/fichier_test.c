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
    //                     TEST 1 : sub_bytes
    // ---------------------------------------------------------
    uint8_t debut_SubBytes[4][4] = {
        {0x19, 0xa0, 0x9a, 0xe9},
        {0x3d, 0xf4, 0xc6, 0xf8},
        {0xe3, 0xe2, 0x8d, 0x48},
        {0xbe, 0x2b, 0x2a, 0x08} 
    };

    uint8_t fin_SubBytes[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e}, 
        {0x27, 0xbf, 0xb4, 0x41}, 
        {0x11, 0x98, 0x5d, 0x52}, 
        {0xae, 0xf1, 0xe5, 0x30} 
    };

    sub_bytes(debut_SubBytes);
    printf("Test SubBytes : ");

    if (compare(debut_SubBytes, fin_SubBytes)) {
        printf("True\n\n");
    } else {
        printf("False\n\n");
    }

    // ---------------------------------------------------------
    //                     TEST 2 : inv_sub_bytes
    // ---------------------------------------------------------

    uint8_t fin_InvSubBytes[4][4] = {
        {0x19, 0xa0, 0x9a, 0xe9},
        {0x3d, 0xf4, 0xc6, 0xf8},
        {0xe3, 0xe2, 0x8d, 0x48},
        {0xbe, 0x2b, 0x2a, 0x08} 
    };

    uint8_t debut_InvSubBytes[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e}, 
        {0x27, 0xbf, 0xb4, 0x41}, 
        {0x11, 0x98, 0x5d, 0x52}, 
        {0xae, 0xf1, 0xe5, 0x30} 
    };

    inv_sub_bytes(debut_InvSubBytes);
    printf("Test InvSubBytes : ");

    if (compare(debut_InvSubBytes, fin_InvSubBytes)) {
        printf("True\n\n");
    } else {
        printf("False\n\n");
    }

    // ---------------------------------------------------------
    //                     TEST 3 : shift_rows
    // ---------------------------------------------------------

    uint8_t debut_ShiftRows[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e}, 
        {0x27, 0xbf, 0xb4, 0x41}, 
        {0x11, 0x98, 0x5d, 0x52}, 
        {0xae, 0xf1, 0xe5, 0x30} 
    };

    uint8_t fin_ShiftRows[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e},
        {0xbf, 0xb4, 0x41, 0x27},
        {0x5d, 0x52, 0x11, 0x98},
        {0x30, 0xae, 0xf1, 0xe5} 
    };
    shift_rows(debut_ShiftRows);

    printf("Test ShiftRows : ");

    if (compare(debut_ShiftRows, fin_ShiftRows)) {
        printf("True\n\n");
    } else {
        printf("False\n\n");
    }

    // ---------------------------------------------------------
    //                     TEST 4 : inv_shift_rows
    // ---------------------------------------------------------
    
    uint8_t fin_InvShiftRows[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e}, 
        {0x27, 0xbf, 0xb4, 0x41}, 
        {0x11, 0x98, 0x5d, 0x52}, 
        {0xae, 0xf1, 0xe5, 0x30} 
    };

    uint8_t debut_InvShiftRows[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e},
        {0xbf, 0xb4, 0x41, 0x27},
        {0x5d, 0x52, 0x11, 0x98},
        {0x30, 0xae, 0xf1, 0xe5} 
    };
    inv_shift_rows(debut_InvShiftRows);

    printf("Test InvShiftRows : ");

    if (compare(debut_InvShiftRows, fin_InvShiftRows)) {
        printf("True\n\n");
    } else {
        printf("False\n\n");
    }

    // ---------------------------------------------------------
    //                     TEST 5 : MixColumns 
    // ---------------------------------------------------------
    uint8_t debut_mix[4][4] = {
        {0xd4, 0xe0, 0xb8, 0x1e},
        {0xbf, 0xb4, 0x41, 0x27},
        {0x5d, 0x52, 0x11, 0x98},
        {0x30, 0xae, 0xf1, 0xe5} 
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
    //                  TEST 6 : InvMixColumns
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

    // ---------------------------------------------------------
    //                  TEST 7 : keyExpension
    // ---------------------------------------------------------

    uint8_t output[44][4];
    uint8_t Cipher_key [16] = {0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c};

    keyExp(Cipher_key,output);
    for(int i = 0; i < 40; i++){
        printf("\n\n");
        for(int j = 0; j < 4; j++){
            printf("%02x", output[i][j]);
        }
    }   

    uint8_t State[4][4] = {
        {0x19, 0xa0, 0x9a, 0xe9},
        {0x3d, 0xf4, 0xc6, 0xf8},
        {0xe3, 0xe2, 0x8d, 0x48},
        {0xbe, 0x2b, 0x2a, 0x08} 
    };
    sub_bytes(State);
    shift_rows(State);
    mix_columns(State);
    print_state(State);

    AddRoundKey(State, output,1);
    printf("\n");
    print_state(State);

    return 0;
}