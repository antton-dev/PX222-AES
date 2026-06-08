{-
@author       : Antton Chevrier and Lucas Fernandez
@organization : Grenoble INP - Esisar, UGA
@groupe       : TD 1 - Binome 3
@project      : PX222 MATHS-INFO - AES
@file         : Aes.hs
@description  : Algorithmes de AES
-}

{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use camelCase" -}

module Aes where
import Structures
import Math
import Numeric (showHex, readHex)

type State = [WordAES]

-- Applique la multiplication matricielle et l’addition de la constante specifiees par la transformation affine de la doc fips.
affine_transfo (GF256 (P input)) = GF256 (P (reverse new_byte)) where 

    -- Completer avec des zeros pour atteindre 8 bit exactement, et reverse pour aligner les index
    byte = reverse (replicate (8 - length input) zero  ++   input) 

    c = reverse [zero, un, un, zero, zero, zero, un, un]

    -- formule de la doc, on utilise un foldl pour accumuler les XOR (soit des add dans Z2)
    new_bit i = foldl add zero [
                    byte!!i, 
                    byte!!((i+4) `mod` 8),
                    byte!!((i+5) `mod` 8) , 
                    byte!!((i+6) `mod` 8), 
                    byte!!((i+7) `mod` 8), 
                    c!!i
                ]

    -- Construction de nouvel octet
    new_byte = [new_bit i | i<- [0..7]]


-- Calcule l’inverse multiplicatif de l’octet dans GF 256 puis lui applique la transformation affine.
sBox :: GF256 Z2 -> GF256 Z2
sBox x =  affine_transfo (inverse x) where 
    inverse x = case (inv_mul x) of 
        Just inv -> inv 
        Nothing -> zero
    


-- Applique la sBox à chaque octet d'un mot passé en parametre
subBytes_word :: WordAES -> WordAES
subBytes_word (WordAES (P bytes)) = WordAES (P (map sBox bytes))

-- Application pour les 4 mots de l'état
-- appelé subWord() dans la documentation
subBytes :: State -> State
subBytes = map subBytes_word 

-- Decale cycliquement vers la gauche les trois dernieres lignes de l’etat avec des pas respectifs de 1, 2 et 3 octets.
shift_rows :: State -> State
shift_rows [WordAES (P [s00, s10, s20, s30]),
            WordAES (P [s01, s11, s21, s31]),
            WordAES (P [s02, s12, s22, s32]),
            WordAES (P [s03, s13, s23, s33])] = 
    [
        WordAES (P [s00, s11, s22, s33]),
        WordAES (P [s01, s12, s23, s30]),
        WordAES (P [s02, s13, s20, s31]),
        WordAES (P [s03, s10, s21, s32])
    ]

shift_rows _ = error "Erreur : La taille de l'etat State est invalide pour ShiftRows"


-- Convertit un octet en hexadecimale completee par un zero si necessaire.
showHexByte :: GF256 Z2 -> String
showHexByte (GF256 (P bits)) = 
    let 
        zeros_manquants = replicate (8 - length bits) (Z2 0)
        bits_8 = zeros_manquants ++ bits
        
        valeur_entiere = bits_vers_entier bits_8
        
        texte_hexa = showHex valeur_entiere ""
    in 
        if valeur_entiere < 16 
        then "0" ++ texte_hexa 
        else texte_hexa


bits_vers_entier :: [Z2] -> Integer
bits_vers_entier [Z2 b7, Z2 b6, Z2 b5, Z2 b4, Z2 b3, Z2 b2, Z2 b1, Z2 b0] = 
    (b7 * 128) + (b6 * 64) + (b5 * 32) + (b4 * 16) + (b3 * 8) + (b2 * 4) + (b1 * 2) + (b0 * 1)
bits_vers_entier _ = 0 

-- Affiche la matrice d’etat AES sous forme d’un tableau d’octets hexadecimaux.
printState :: [WordAES] -> IO ()
printState colonnes = do
    let lignExtract i = unwords [showHexByte (octets !! i) | WordAES (P octets) <- colonnes]
    
    putStrLn (lignExtract 0)
    putStrLn (lignExtract 1)
    putStrLn (lignExtract 2)
    putStrLn (lignExtract 3)


hex01 :: GF256 Z2
hex01 = GF256 (P [Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 1])

hex02 :: GF256 Z2
hex02 = GF256 (P [Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 1, Z2 0])

hex03 :: GF256 Z2
hex03 = GF256 (P [Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 0,Z2 1, Z2 1])

a_x :: WordAES
a_x = WordAES (P [hex03, hex01, hex01, hex02])

-- Multiplie une colonne d’etat par le polynome de l’AES modulo X^4 + 1.
mix_single_column :: WordAES -> WordAES -> WordAES
mix_single_column p_x (WordAES (P colonne_liste)) = 
    let 
        vrai_poly = WordAES (P (reverse colonne_liste))
        WordAES (P resultat_brut) = mul p_x vrai_poly
        pad_zeros = replicate (4 - length resultat_brut) zero
        resultat_pad = pad_zeros ++ resultat_brut
    in 
        WordAES (P (reverse resultat_pad))

-- multiplie individuellement chaque colonne par le polynome predefini.
mixColumns :: State -> State
mixColumns = map (mix_single_column a_x)

-- Key Expansion
rotWord :: WordAES -> WordAES 
rotWord (WordAES (P [a, b, c, d])) = WordAES (P [b, c, d, a])

-- Calcule la constante multiplicative de tour necessaire au processus d’expansion de la cle.
rc :: Integer -> GF256 Z2
rc 1 = un
rc i = GF256 (P [un, zero]) `mul` (rc (i-1))



-- Genere un mot AES en combinant la valeur de rc(i) avec trois octets nuls.
rcon :: Integer -> WordAES
rcon i = WordAES (P [rc i, zero, zero, zero]) 

-- Decoupe une suite de mots de cle en blocs de sous-cles de tour exploitables par l’algorithme.
split4 :: [WordAES] -> [State]
split4 [] = []
split4 xs = take 4 xs : split4 (drop 4 xs)

-- Determine la cle du tour suivant par substitution, rotation et application de la constante de tour selon l'un des 3 modes.
next_round_key :: Integer -> Integer -> State -> State
next_round_key 128 i [w0, w1, w2, w3] = [w0_new, w1_new, w2_new, w3_new] where
    w0_new = w0 `add` (subBytes_word (rotWord w3)) `add` rcon i
    w1_new = w1 `add` w0_new
    w2_new = w2 `add` w1_new
    w3_new = w3 `add` w2_new

next_round_key 192 i [w0, w1, w2, w3, w4, w5] = [w0_new, w1_new, w2_new, w3_new, w4_new, w5_new] where
    w0_new = w0 `add` subBytes_word (rotWord w5) `add` rcon i
    w1_new = w1 `add` w0_new
    w2_new = w2 `add` w1_new
    w3_new = w3 `add` w2_new
    w4_new = w4 `add` w3_new
    w5_new = w5 `add` w4_new

next_round_key 256 i [w0, w1, w2, w3, w4, w5, w6, w7] = [w0_new, w1_new, w2_new, w3_new, w4_new, w5_new, w6_new, w7_new] where 
    w0_new = w0 `add` subBytes_word (rotWord w7) `add` rcon i
    w1_new = w1 `add` w0_new
    w2_new = w2 `add` w1_new
    w3_new = w3 `add` w2_new
    w4_new = w4 `add` subBytes_word w3_new  
    w5_new = w5 `add` w4_new
    w6_new = w6 `add` w5_new
    w7_new = w7 `add` w6_new

next_round_key _ _ _ = error "Incohérence entre la taille de la clé est le mode AES"


-- Produit par recurrence l’integralite des cles de tours requises.
generate_keys_128 :: Integer -> State -> [State]
generate_keys_128 11 _ = [] 
generate_keys_128 i previous_key = next_key : generate_keys_128 (i+1) next_key where
    next_key = next_round_key 128  i previous_key

-- Produit par recurrence l’integralite des cles de tours requises.
generate_keys_192 :: Integer -> State -> [State]
generate_keys_192 9 _ = [] 
generate_keys_192 i previous_key = next_key : generate_keys_192 (i+1) next_key where
    next_key = next_round_key 192 i previous_key

-- Produit par recurrence l’integralite des cles de tours requises.
generate_keys_256 :: Integer -> State -> [State]
generate_keys_256 15 _ = [] 
generate_keys_256 i previous_key = next_key : generate_keys_256 (i+1) next_key where
    next_key = next_round_key 256 i previous_key


-- Genere la planifification des cles de tours d’AES a partir de la cle de l'utilisateur.
keyExpansion :: Integer -> [WordAES] -> [State]
keyExpansion 128 key = 
    let all_words = concat (key : generate_keys_128 1 key)
    in split4 (take 44 all_words)

keyExpansion 192 key = 
    let all_words = concat (key : generate_keys_192 1 key)
    in split4  (take 52 all_words) 

keyExpansion 256 key = 
    let all_words = concat (key : generate_keys_256 1 key)
    in split4  (take 60 all_words) 

keyExpansion _ _ = error "Taille de cle non supportee"

-- Affiche toutes les clés d'une liste avec leur numéro de tour
printAllKeys :: [State] -> Int -> IO ()
printAllKeys [] _ = return ()
printAllKeys (cle:reste) numeroTour = do
    putStrLn ("\n--- Cle du Tour " ++ show numeroTour ++ " ---")
    printState cle
    printAllKeys reste (numeroTour + 1)

-- Additionne bit a bit chaque element de l’etat courant avec la sous-cle de tour correspondante.
addRoundKey :: State -> State -> State
addRoundKey s k = zipWith xor_col s k where
    xor_col (WordAES (P c1)) (WordAES (P c2)) = WordAES (P new_bytes)
        where 
            c1_pad = replicate (4 - length c1) zero ++ c1
            c2_pad = replicate (4 - length c2) zero ++ c2
            
            new_bytes = [ add a b | (a, b) <- zip c1_pad c2_pad ]


{-- INVERSE CYPHER --}

inv_shift_rows :: State -> State
inv_shift_rows [
        WordAES (P [s00, s11, s22, s33]),
        WordAES (P [s01, s12, s23, s30]),
        WordAES (P [s02, s13, s20, s31]),
        WordAES (P [s03, s10, s21, s32])] = 
    [
        WordAES (P [s00, s10, s20, s30]),
        WordAES (P [s01, s11, s21, s31]),
        WordAES (P [s02, s12, s22, s32]),
        WordAES (P [s03, s13, s23, s33])]

inv_shift_rows _ = error "Erreur : La taille de l'etat State est invalide pour ShiftRows"

b_x :: WordAES
b_x = 
    let 
        x4 = P [un, zero, zero, zero, un]
        a_x = P [hex03, hex01, hex01, hex02]
        
    in 
        case inverse_modulaire x4 a_x of
            Just inverse -> WordAES inverse

inv_Mix_Columns :: State -> State
inv_Mix_Columns = map (mix_single_column b_x)


inv_affine :: GF256 Z2 -> GF256 Z2
inv_affine (GF256 (P input)) = GF256 (P (reverse new_byte)) where 

    byte_original = reverse (replicate (8 - length input) zero ++ input) 
    c = reverse [zero, un, un, zero, zero, zero, un, un]

    byte_plus_c = [ add (byte_original !! i) (c !! i) | i <- [0..7] ]

    new_bit i = foldl add zero [
                    byte_plus_c !! ((i+2) `mod` 8),
                    byte_plus_c !! ((i+5) `mod` 8), 
                    byte_plus_c !! ((i+7) `mod` 8)
                ]

    new_byte = [new_bit i | i <- [0..7]]



inv_sBox :: GF256 Z2 -> GF256 Z2
-- L'ordre reste le même : on défait l'affine, puis on fait l'inversion modulaire
inv_sBox x = inverse (inv_affine x) where 
    inverse octet = case inv_mul octet of 
        Just inv -> inv 
        Nothing  -> zero

inv_subBytes_word :: WordAES -> WordAES
inv_subBytes_word (WordAES (P bytes)) = WordAES (P (map inv_sBox bytes))


inv_subBytes :: State -> State
inv_subBytes = map inv_subBytes_word 




-- Conversion hexa -> binary
int_to_bin :: Integer -> GF256 Z2
int_to_bin n =GF256 (clean_poly (P (map Z2 bits))) where
    bits = [n `div` (2^i) `mod` 2 | i <- reverse [0..7]]
     

-- Convertit une chaîne hexadécimale (par exemple "2b") en GF256 Z2
hex_to_bin :: String -> GF256 Z2
hex_to_bin str = 
    case readHex str of
        [(val, "")] -> int_to_bin val