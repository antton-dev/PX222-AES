{-
@author       : Antton Chevrier and Lucas Fernandez
@organization : Grenoble INP - Esisar, UGA
@groupe       : TD 1 - Binome 3
@project      : PX222 MATHS-INFO - AES
@file         : Structures.hs
@description  : Structures algébriques requises pour AES
-}

module Structures where

-- Groupe
class Groupe a where 
    add :: a -> a -> a  -- ou op a voir
    zero :: a
    inv_add :: a -> a

-- Anneau
class (Groupe a) => Anneau a where
    mul :: a -> a -> a 
    un :: a

-- Corps
class (Anneau a) => Corps a where
    inv_mul :: a -> Maybe a