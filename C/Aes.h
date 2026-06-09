#ifndef AES_H
#define AES_H
#include <stdint.h>

static const uint8_t sbox[256];
static const uint8_t Rcon[10];
static const uint8_t inverse_sbox[256];
typedef uint8_t state;
typedef uint8_t word;


void print_state(state State[4][4]);
void SubWord(word word[4]);
void RotWord(word word[4]);
uint8_t mul_02(uint8_t x);
uint8_t mul_03(uint8_t x);
uint8_t mul_09(uint8_t x);
uint8_t mul_0b(uint8_t x);
uint8_t mul_0d(uint8_t x);
uint8_t mul_0e(uint8_t x);

// Fonction pour le cypher
void sub_bytes(state State[4][4]);
void shift_rows(state State[4][4]);
void mix_columns(state State[4][4]);
void keyExp(word *key, uint8_t w_output[60][4], int key_length);
void AddRoundKey(state State[4][4], uint8_t w_output[60][4], int round);

//fonction pour le decypher
void inv_shift_rows(state State[4][4]);
void inv_mix_columns(state State[4][4]);
void inv_sub_bytes(state State[4][4]);



#endif