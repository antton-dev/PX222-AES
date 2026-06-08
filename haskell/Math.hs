{-
@author       : Antton Chevrier and Lucas Fernandez
@organization : Grenoble INP - Esisar, UGA
@groupe       : TD 1 - Binome 3
@project      : PX222 MATHS-INFO - AES
@file         : Math.hs
@description  : Concepts mathématiques d'AES
-}

{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use camelCase" -}

module Math where

import Structures

-- Convention : Terme de plus au degré du polynome à l'indice 0 de la liste

-- ============= Types =============
data Z2 = Z2 Integer deriving (Show, Eq)

data P a = P [a] deriving (Show, Eq)

data GF256 a = GF256 (P a) deriving (Show, Eq) 

data WordAES = WordAES (P (GF256 Z2)) deriving (Show, Eq)


m :: (Structures.Corps a, Eq a) => P a
m = P ([un, zero, zero, zero, un, un, zero, un, un])

-- ============= Instances =============
----------------     Z2     ------------
instance Structures.Groupe Z2 where
    add (Z2 a) (Z2 b) = Z2 $ (a+b) `mod` 2
    zero = Z2 0
    inv_add (Z2 x) = Z2 $ (0-x) `mod` 2

instance Structures.Anneau Z2 where
    mul (Z2 a) (Z2 b) = Z2 $ (a*b) `mod` 2
    un = Z2 1

instance Structures.Corps Z2 where
    inv_mul (Z2 0) = Nothing
    inv_mul (Z2 1) = Just (Z2 1)


----------------    Z2[X]   ------------
-- Si le compilo peut garantir que a verifie une structure de groupe, alors on défini une structure de groupe pour les polynomes à coefficients de type a
instance (Structures.Groupe a, Eq a) => Structures.Groupe (P a) where
    zero  = P []
    inv_add (P p) = P (map inv_add p)
    add = add_poly

instance (Structures.Anneau a, Eq a) => Structures.Anneau (P a) where
    un = P [un]
    mul = mul_poly


----------------    GF256   ------------
instance (Structures.Groupe a, Eq  a) => Structures.Groupe (GF256 a) where
    add (GF256 p) (GF256 q) = GF256 (add p q)
    zero = GF256 zero
    inv_add (GF256 p) = GF256 (inv_add p)

instance (Structures.Corps a, Eq a) => Structures.Anneau (GF256 a) where 
    un = GF256 un 
    mul (GF256 p) (GF256 q) = case div_eucli (mul p q) m  of 
        Just (_, reste) -> GF256 reste


instance (Structures.Corps a, Eq a) => Structures.Corps (GF256 a) where 
    inv_mul (GF256 p) | p == zero  = Nothing
                      | otherwise  = case inverse_modulaire m p of
                        Just inverse -> Just (GF256 inverse) 
                        Nothing -> Nothing

----------------  GF256[X]  ------------
instance Structures.Groupe WordAES where 
    add (WordAES a) (WordAES b) = WordAES (add a b)
    zero = WordAES zero
    inv_add (WordAES a) = WordAES (inv_add a)

instance Structures.Anneau WordAES where 
    un = WordAES un
    mul = mul_word 


-- ============= Functions =============
add_l :: Structures.Groupe a => [a] -> [a] -> [a]
add_l [] ys = ys
add_l xs [] = xs
add_l (x:xs) (y:ys) = add x y : add_l xs ys

-- Realise l’addition de deux polynomes en ajustant d’abord leurs tailles respectives pour aligner les puissances.
add_poly :: (Structures.Groupe a, Eq a) => P a -> P a -> P a
add_poly (P p) (P q) = clean_poly (P result) where
    result = add_l paddedP paddedQ
    paddedP = if length p < length q then replicate (length q - length p) zero ++ p else p -- aligne les termes de chaque degré pour l'addition 
    paddedQ = if length q < length p then replicate (length p - length q) zero ++ q else q

-- Multiplie deux polynomes.
mul_poly :: (Structures.Anneau a, Eq a) => P a -> P a -> P a
mul_poly (P a)(P b) = P (mul_l a b)
        where
            mul_l [] ys = []
            mul_l xs [] = []
            mul_l l1@(x:xs) l2@(y:ys) = add_l (map (mul x) l2) (zero : mul_l xs l2)

--Execute la division euclidienne polynomiale classique et s’arrete lorsque le degre du reste est inferieur a celui du diviseur.
div_eucli :: (Structures.Corps a, Eq a) => P a -> P a -> Maybe (P a, P a)
div_eucli p_brut q_brut | degree q == -1       = Nothing                                            -- division par le polynome nul
                        | degree  p < degree q = Just (zero, p_brut)                                -- condition d'arret recursivite, si deg P < deg Q alors la div_eucli est fini
                        | otherwise =                                                               -- Cas récursif                     
                            case div_eucli reste_inter q of
                                Just (quo_suite, r_final) -> Just (add quo quo_suite, r_final)      -- Résultat final, on additionne les quo_suite un par un pour former le reste 
                                Nothing -> Nothing
    where
        P (a:_) = p
        P (b:_) = q

        p = clean_poly p_brut
        q = clean_poly q_brut

        reste_inter = add p (inv_add (mul quo q)) -- P = Q * quo + R => R = P - Q * quo

        quo = P (c : replicate diff zero) --  création du quotient 
        diff = degree p - degree q -- détermine le degré que devra avoir le quotient 
        c = case inv_mul b of 
            Just inv_b -> mul a inv_b -- a * b^-1

-- | Algorithme d'Euclide étendu
-- Renvoie un tuple (PGCD, U, V) tel que : A * U + B * V = PGCD
euclide_etendu :: (Structures.Corps a, Eq a) => P a -> P a -> Maybe (P a, P a, P a)
euclide_etendu polynome_a polynome_b =
    -- On lance la boucle récursive avec les valeurs initiales mathématiques standard :
    -- R0 = A, R1 = B
    -- U0 = 1, U1 = 0
    -- V0 = 0, V1 = 1
    etape_euclide polynome_a polynome_b un zero zero un


-- | La fonction qui remplace la boucle "while"
etape_euclide :: (Structures.Corps a, Eq a) => P a -> P a -> P a -> P a -> P a -> P a -> Maybe (P a, P a, P a)
etape_euclide r0 r1 u0 u1 v0 v1 | degree r1 == -1 = Just (r0, u0, v0) -- Si R1 == 0, PGCD = R0 coeff de Bézout : U0 et V0.
                                | otherwise = -- r /= 0 
                                    case div_eucli r0 r1 of
                                        Nothing -> Nothing
                                        Just (quotient, reste_division) -> etape_euclide new_r0 new_r1 new_u0 new_u1 new_v0 new_v1 -- extrait le quotient et le nouveau reste
                                            where
                                                new_r0 = r1
                                                new_r1 = reste_division

                                                -- Unouveau = Uancien - (Quotient * Uactuel)
                                                new_u0 = u1
                                                produit_u  = mul quotient u1

                                                new_u1 = add u0 (inv_add produit_u) 

                                                -- Vnouveau = Vancien - (Quotient * Vactuel)
                                                new_v0 = v1
                                                produit_v  = mul quotient v1

                                               
                                                new_v1 = add v0 (inv_add produit_v)           


-- Determine l’inverse d’un polynome modulo M (X) en exploitant les coefficients fournis par l’algorithme d’Euclide etendu.
inverse_modulaire :: (Structures.Corps a, Eq a) => P a -> P a -> Maybe (P a)
inverse_modulaire poly_mod polynome_cible 
    | degree polynome_cible == -1 = Nothing
    | otherwise = case euclide_etendu poly_mod polynome_cible of
        Nothing -> Nothing
        Just (pgcd_brut, u, v) -> 
            let pgcd = clean_poly pgcd_brut
            in if degree pgcd == 0 
               then 
                   let P [c] = pgcd 
                   in case inv_mul c of
                          Just inv_c -> Just (mul (P [inv_c]) (clean_poly v))
                          Nothing    -> Nothing
               else Nothing           


-- nettoyage des termes inutiles dans un polynome. 
-- Par exemple, le polynome [0, 1, 1] (longueur 3) est le polynome 0X²+1X+1 (degré 1) soit le polynome X+1, qui doit donc être représenté par [1, 0] (longueur 2) afin de garantir que la longueur de la liste soit bien le degré du polynome
clean_poly :: (Structures.Groupe a, Eq a) => P a -> P a
clean_poly (P []) = P []
clean_poly (P (x:xs)) | x == zero  = clean_poly (P xs)
                      | otherwise  = P (x:xs)

-- Calcule le degre du polynome apres avoir nettoye ses termes nuls de tete.
degree :: (Structures.Groupe a, Eq a) => P a -> Int
-- impossible de length un P : on fait du pattern matching pour recuperer la liste "cleaned", puisque un polynome est  défini comme P [a]. On récupère donc [a]
degree p = length cleaned - 1 where
            P cleaned = clean_poly p

-- Construit et normalise un element de GF (256) en un polynome.
make_GF256 :: [Integer] -> GF256 Z2
make_GF256 liste = GF256 (clean_poly (P (map Z2 liste)))

--Effectue la multiplication de deux mots AES consideres comme des polynomes modulo X^4 + 1.
mul_word :: WordAES -> WordAES -> WordAES
mul_word (WordAES p) (WordAES q) = case div_eucli (mul p q) (P [un, zero, zero, zero, un]) of 
    Just (_, reste) -> WordAES reste