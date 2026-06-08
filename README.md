# Carnet de bord PX222 MATHS INFO
Par Antton CHEVRIER et Lucas FERNANDEZ

------------------ 

# Séance 1 - Vendredi 13 mars 2026
## Réalisé en séance
- Implémentation de la class `Anneau`
- Implémentation et test de l'anneau quotient $\Z/2\Z$  (`Z2`)
- Implémentation de l'anneau des polynomes dans $\Z/2\Z$  
    - addition testée et fonctionnelle sauf pour le cas avec deux listes de tailles differentes => Il faudra déterminer si c'est un bug ou une fonctionnalité
    - multiplication en cours d'implémentation

## A réaliser pour la prochaine séance
|  Statut  |     Tâche                                                            | Membre    |
|----------|----------------------------------------------------------------------|---------- |
| Done     | **Finir la multiplication pour $GF(2)[X]$**                          | Lucas     |
| Done     | **Instanciation de $GF(2^8)$**                                       | Deux      |
| Done     | *(sous-tache)* Division euclidienne                                  | Antton    |
| Done     | *(sous-tache)* Euclide étendu                                        | Lucas     |
| à faire  | *(sous-tache)* $GF(2^8)$                                             | Lucas     |
| à faire  | **Instanciation de $GF(2^8)[X]$**                                    | deux      |
| Done     | **Réfléchir à une architecture pour les fichiers sources**           | deux      |
| Done     | **Finaliser / Completer les tests déjà faits**                       | deux      |
| Done     | **Corriger le problème d'addition de listes de tailles différentes** | Antton    | 


# Séance 2 - Mercredi 1er avril 2026
## réalisé en séance
- instanciation de $GF256$ (Groupe, Anneau et Corps)
- $GF256[X]$ n'est qu'une application de nos polynomes, définis pour n'importe quel type, à GF256
- début de la multiplication modulo $X^4+1$ dans $GF256[X]$

## A réaliser pour la prochaine séance
|     Tâche                                                            | Membre    |
|----------------------------------------------------------------------|---------- |
| **Finir la multiplication modulo $X^4+1$ dans $GF256[X]$**           | Antton    |
| **Commencer `subBytes()` (Chiffrement)**                             | Antton    |
| **Commencer `ShiftRows()`**                                          | Lucas     |


## Réalisé entre les séances
| Statut   |     Tâche                                                            | Membre    |
|----------|----------------------------------------------------------------------|---------- |
| fait     | **Finir la multiplication modulo $X^4+1$ dans $GF256[X]$**           | Antton    |
| fait     | **Instanciation de l'anneau $GF256[X]$, appelé `WordAES`**           | Antton    |
| fait     | **Implémenter `subBytes()` (Chiffrement)**                           | Antton    |
| fait     | *(sous tâche)* Implémenter la S-Box                                  | Antton    |
| fait     | *(sous tâche)* Implémenter l'algo de `subBytes()`                    | Antton    |   
| fait     | **Commencer `ShiftRows()`**                                          | Lucas     |
| fait     | **finir `ShiftRows()`**                                              | Lucas     |
| fait     | faire un affichage lisible de l'état (sous forme de matrice en hexa) | Lucas     |
| fait     | **Implémentation de `mixColumns`**                                   | Lucas     |     




# Séance 3 - Mardi 21 avril 2026
## réalisé en séance
- inversion des fonctions `ShiftRows()` et `Mix_Columns()`
- Début de l'expansion de la clé
- Début de l'inverse de `subBytes()`

## A réaliser pour la prochaine séance
|     Tâche                                                            | Membre    |
|----------------------------------------------------------------------|---------- |
| **Finir la `KeyExpansion`**                                          | Antton    |
| **Faire `addRoundKey`**                                              | à définir |
| **Inverser `subBytes()`**                                            | À deux    |
| **Inverser `addRoundKey`**                                           | Lucas     |

## Réalisé entre les séances
|  Statut  |     Tâche                                                            | Membre    |
|----------|----------------------------------------------------------------------|---------- |
| fait     | **Finir la `KeyExpansion`**                                          | Antton    |
| fait     | **Faire `addRoundKey`**                                              | Lucas     | 
| fait     | **Inverser `subBytes()`**                                            | Lucas     |
| fait     | **Algo de chiffrement `cipher`**                                     | Antton    |
| fait     | **Algo de déchiffrement `Decipher`**                                 | Lucas     |


# Séance 4 - Mercredi 06 mai 2026
- modification de `addRoundKey`
- modificatiion de `inversecipher`
- Implémentation de `AES-192` et `AES-256`
- création d'une fonction qui prend un Hexa et qui le transforme en binaire 
- Implémentation de `ShiftRows` en C


