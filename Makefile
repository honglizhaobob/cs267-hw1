# on Hopper, we will benchmark you against Cray LibSci, the default vendor-tuned BLAS. The Cray compiler wrappers handle all the linking. If you wish to compare with other BLAS implementations, check the NERSC documentation.
# This makefile is intended for the GNU C compiler. On Hopper, the Portland compilers are default, so you must instruct the Cray compiler wrappers to switch to GNU: type "module swap PrgEnv-pgi PrgEnv-gnu"

ifdef UBUNTU
  CC = gcc 
  LDLIBS = -lrt -lblas
else
  CC = cc
  LDLIBS = -lrt
endif

OPT = -O1
CFLAGS = -Wall -std=gnu99 $(OPT)
LDFLAGS = -Wall
# librt is needed for clock_gettime

targets = benchmark-naive benchmark-blocked-baseline benchmark-blas benchmark-blocked
objects = benchmark.o dgemm-naive.o dgemm-blocked-baseline.o dgemm-blas.o dgemm-blocked

.PHONY : default
default : all

.PHONY : all
all : clean $(targets)

benchmark-naive : benchmark.o dgemm-naive.o 
	$(CC) -o $@ $^ $(LDLIBS)
benchmark-blocked-baseline : benchmark.o dgemm-blocked-baseline.o
	$(CC) -o $@ $^ $(LDLIBS)
benchmark-blas : benchmark.o dgemm-blas.o
	$(CC) -o $@ $^ $(LDLIBS)
benchmark-blocked : benchmark.o dgemm-blocked.o 
	$(CC) -o $@ $^ $(LDLIBS)

%.o : %.c
	$(CC) -c $(CFLAGS) $<

.PHONY : clean
clean:
	rm -f $(targets) $(objects)