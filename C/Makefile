

all: fichier_test cipher decipher

fichier_test: fichier_test.c Aes.c Aes.h cipher.c cipher.h decipher.c decipher.h
	gcc -Wall -Wextra -o fichier_test fichier_test.c Aes.c cipher.c decipher.c

cipher: cipher.c Aes.c Aes.h cipher.h
	gcc -Wall -Wextra -o cipher cipher.c Aes.c

decipher: decipher.c Aes.c Aes.h decipher.h
	gcc -Wall -Wextra -o decipher decipher.c Aes.c

clean:
	rm -f fichier_test cipher decipher 