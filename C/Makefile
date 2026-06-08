all: fichier_test cipher decipher

fichier_test: fichier_test.c Aes.c
	gcc -Wall -Wextra -O2 -o fichier_test fichier_test.c Aes.c

cipher: cipher.c Aes.c
	gcc -Wall -Wextra -o cipher cipher.c Aes.c

decipher: decipher.c Aes.c
	gcc -Wall -Wextra -o decipher decipher.c Aes.c

clean:
	rm -f fichier_test cipher decipher