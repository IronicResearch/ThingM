# Makefile for console test apps

CC	?= gcc
CXX	?= g++

OBJS	= hex2bin.o

LIBS	=

EXES	= hex2bin

.PHONY:	all
all:	$(EXES)

hex2bin:	hex2bin.o
	$(CXX) $(CFLAGS) $(LDFLAGS) -o hex2bin hex2bin.o $(LIBS)

.PHONY:	clean
clean: 
	rm -f $(OBJS) $(EXES) *.o
