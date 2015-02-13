# on Hopper, we will benchmark you against Cray LibSci, the default vendor-tuned BLAS. The Cray compiler wrappers handle all the linking. If you wish to compare with other BLAS implementations, check the NERSC documentation.
# This makefile is intended for the GNU C compiler. On Hopper, the Portland compilers are default, so you must instruct the Cray compiler wrappers to switch to GNU: type "module swap PrgEnv-pgi PrgEnv-gnu"

ifdef UBUNTU
  CC = gcc -D_GNU_SOURCE=1
  LDLIBS = -lrt -lblas -lm
  OSFOUND=1
endif
ifdef OSX
  CC = gcc
  LDLIBS = -lblas
  OSFOUND=1
endif
ifndef OSFOUND
  CC = cc
  LDLIBS = -lrt
endif

ifdef DEBUG
  INSTRUMENTATION = -g
endif
ifdef PROFILE
  INSTRUMENTATION = -pg -g
endif

ifdef FULL_OPT
  OPTIMIZATION = -O3
else
  OPTIMIZATION = -O1
endif

OPT = $(INSTRUMENTATION) $(OPTIMIZATION)

CFLAGS = -Wall -std=gnu99 $(OPT)
LDFLAGS = -Wall

targets = benchmark-naive benchmark-blocked-baseline benchmark-blas benchmark-blocked benchmark-simd test-blocked
objects = benchmark.o unit-test-framework.o dgemm-tests.o dgemm-naive.o dgemm-blocked-baseline.o dgemm-blas.o dgemm-blocked.o dgemm-simd.o matrix-blocking.o matrix-storage.o

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
benchmark-blocked : benchmark.o dgemm-blocked.o matrix-blocking.o matrix-storage.o
	$(CC) -o $@ $^ $(LDLIBS)
test-blocked : dgemm-tests.o unit-test-framework.o dgemm-blocked.o matrix-blocking.o matrix-storage.o
	$(CC) -o $@ $^ $(LDLIBS)
benchmark-simd : benchmark.o dgemm-simd.o
	$(CC) -DCLS=$(getconf LEVEL1_DCACHE_LINESIZE) -O3 -o $@ $^ $(LDLIBS)

%.o : %.c
	$(CC) -c $(CFLAGS) $<

.PHONY : clean
clean:
	rm -f $(targets) $(objects)
