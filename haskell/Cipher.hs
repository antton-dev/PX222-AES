{-
@author       : Antton Chevrier and Lucas Fernandez
@organization : Grenoble INP - Esisar, UGA
@groupe       : TD 1 - Binome 3
@project      : PX222 MATHS-INFO - AES
@file         : Cipher.hs
@description  : Algorithme de chiffrement
-}

{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use camelCase" -}

module Cipher where
import Structures
import Math
import Aes
import Numeric (showHex)


-- Enchaıne les tours de chiffrement en appliquant successivement les operations SubBytes, ShiftRows, MixColumns et AddRoundKey.
rounds :: State -> [State] -> State
-- cas d'arret de la recursivité - dans la doc figure 5, partie après la boucle for
rounds state [key] = addRoundKey state_shift key where
    state_shift = shift_rows state_sub
    state_sub   = subBytes state

-- recursivité - doc figure 5 : boucle for
rounds state (k:ks) = rounds state_add ks where
    state_add = addRoundKey state_mix k
    state_mix = mixColumns state_shift
    state_shift = shift_rows state_sub
    state_sub = subBytes state 

-- Effectue le chiffrement d’un bloc en initialisant l’etat et en faisant l’ensemble des tours de chiffrement.
cipher ::  Integer -> State -> State -> State
cipher mode input key = rounds initial_state (tail key_schedule) where 

    initial_state = addRoundKey input (head key_schedule)

    key_schedule = keyExpansion mode key
