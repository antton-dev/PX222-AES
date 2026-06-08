#ifndef AES_H
#define AES_H
#include <stdint.h>

static const uint8_t sbox[256];
static const uint8_t Rcon[10];
static const uint8_t inverse_sbox[256];

void print_state(uint8_t State[4][4]);
void SubWord(uint8_t word[4]);
void RotWord(uint8_t word[4]);
uint8_t mul_02(uint8_t x);
uint8_t mul_03(uint8_t x);
uint8_t mul_09(uint8_t x);
uint8_t mul_0b(uint8_t x);
uint8_t mul_0d(uint8_t x);
uint8_t mul_0e(uint8_t x);

// Fonction pour le cypher
void sub_bytes(uint8_t State[4][4]);
void shift_rows(uint8_t State[4][4]);
void mix_columns(uint8_t State[4][4]);
void keyExp(uint8_t key[16], uint8_t w_output[44][4]);
void AddRoundKey(uint8_t State[4][4], uint8_t w_output[44][4], int round);

//fonction pour le decypher
void inv_shift_rows(uint8_t State[4][4]);
void inv_mix_columns(uint8_t State[4][4]);
void inv_sub_bytes(uint8_t State[4][4]);



#endif