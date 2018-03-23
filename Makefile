CC=gcc
CFLAGS=-m64 -Wall
INCLUDE=-I/usr/include/allegro5 -I/usr/include/allegro5/allegro_image
LDFLAGS=-L/usr/lib -lallegro

ASM=nasm
AFLAGS=-f elf64

all:result

main.o: main.c
	$(CC) $(CFLAGS) -c main.c
julia.o: julia.asm
	$(ASM) $(AFLAGS) julia.asm
result: main.o julia.o
	$(CC) $(CFLAGS) main.o julia.o -o result $(INCLUDE) `pkg-config --libs allegro-5.0 allegro_image-5.0`
	rm *.o
clean: 
	rm result
