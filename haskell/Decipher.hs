{-
@author       : Antton Chevrier and Lucas Fernandez
@organization : Grenoble INP - Esisar, UGA
@groupe       : TD 1 - Binome 3
@project      : PX222 MATHS-INFO - AES
@file         : Decypher.hs
@description  : Algorithme de déchiffrement
-}

{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use camelCase" -}

module Decipher where
import Structures
import Math
import Aes
import Numeric (showHex)

-- Enchaıne de facon recursive les etapes de dechiffrement (InvShiftRows, InvSub-Bytes, AddRoundKey et InvMixColumns).
inv_rounds :: State -> [State] -> State
-- cas d'arret de la recursivité - doc figure 12, partie après la boucle for (pas de MixColumns)
inv_rounds state [key] = addRoundKey state_sub key where
    state_sub   = inv_subBytes state_shift
    state_shift = inv_shift_rows state

-- recursivité - doc figure 12 : boucle for du déchiffrement
inv_rounds state (k:ks) = inv_rounds state_mix ks where
    state_mix   = inv_Mix_Columns state_add
    state_add   = addRoundKey state_sub k
    state_sub   = inv_subBytes state_shift
    state_shift = inv_shift_rows state 

--Enchaıne de facon recursive les etapes de dechiffrement (InvShiftRows, InvSub-Bytes, AddRoundKey et InvMixColumns).
decipher :: Integer -> State -> State -> State
decipher mode input key = inv_rounds initial_state (tail rev_key_schedule) where 

    -- On fait le premier AddRoundKey avec la toute dernière clé (la clé n°10)
    initial_state = addRoundKey input (head rev_key_schedule)

    -- On génère toutes les clés, mais on retourne la liste à l'envers [k10, k9, ..., k0]
    rev_key_schedule = reverse (keyExpansion mode key)

     
