N=100

CXX = clang++
OPT = -O3
INC = -I.
CCFLAGS = -Ofast -march=native -funroll-loops -DNDEBUG -fwhole-program #-flto
FCFLAGS = -Ofast -march=native -funroll-loops -DNDEBUG -fwhole-program #-flto
CXXFLAGS = -std=c++14 $(OPT) -march=native -funroll-loops -DNDEBUG  $(INC)

# INCLUDE PATHS AND PACKAGE SPECIFIC FLAGS
# ------------------------------------------------------------------------------------ #
EIGENROOT = /Users/sonderrj/Applications/eigen

BLAZEROOT = /Users/sonderrj/Applications/blaze-3.8.1/include

ARMAROOT = /Users/sonderrj/Applications/armadillo-11.2.3
# ARMA_FLAGS = -DARMA_NO_DEBUG -lblas -llapack
ARMA_FLAGS = -DARMA_NO_DEBUG -larmadillo

XSIMDROOT = /Users/sonderrj/Applications/xsimd
XTLROOT = /Users/sonderrj/Applications/xtl
XTENSORROOT = /Users/sonderrj/Applications/xtensor
XTENSORBLASROOT = /Users/sonderrj/Applications/xtensor_blas
XTENSOR_FLAGS = -I$(XSIMDROOT)/include/ -I$(XTLROOT)/include/ -I$(XTENSORROOT)/include/ -I$(XTENSORBLASROOT)/include/
XTENSOR_FLAGS += -DXTENSOR_USE_XSIMD -lblas -llapack

FASTORROOT = /Users/sonderrj/Applications/Fastor/
FASTOR_FLAGS = -DFASTOR_NO_ALIAS -DFASTOR_DISPATCH_DIV_TO_MUL_EXPR
# ------------------------------------------------------------------------------------ #


ifeq "$(CXX)" "g++"
	CXXFLAGS += -finline-functions -finline-limit=1000000 -ffp-contract=fast
endif
ifeq "$(CXX)" "g++-9"
	CXXFLAGS += -finline-functions -finline-limit=1000000 -ffp-contract=fast
endif
ifeq "$(CXX)" "/usr/local/bin/g++-9"
	CXXFLAGS += -finline-functions -finline-limit=1000000 -ffp-contract=fast
endif

CL_REC_DEPTH = 10000000
ifeq "$(CXX)" "clang++"
	CXXFLAGS += -ftemplate-depth=$(CL_REC_DEPTH) -fconstexpr-depth=$(CL_REC_DEPTH) -foperator-arrow-depth=$(CL_REC_DEPTH)
	CXXFLAGS += -mllvm -inline-threshold=$(CL_REC_DEPTH) -ffp-contract=fast
endif
ifeq "$(CXX)" "c++"
	CXXFLAGS += -ftemplate-depth=$(CL_REC_DEPTH) -fconstexpr-depth=$(CL_REC_DEPTH) -foperator-arrow-depth=$(CL_REC_DEPTH)
	CXXFLAGS += -mllvm -inline-threshold=$(CL_REC_DEPTH) -ffp-contract=fast
endif

ifeq "$(CXX)" "icpc"
	CXXFLAGS += -inline-forceinline -fp-model fast=2
endif

# On some architectures -march=native does not define -mfma
HAS_FMA := $(shell $(CXX) -march=native -dM -E - < /dev/null | egrep "AVX2" | sort)
ifeq ($(HAS_FMA),)
else
CXXFLAGS += -mfma
endif


all:
# 	$(FC) views_loops.f90 -o out_floops.exe $(FCFLAGS)
# 	$(FC) views_vectorised.f90 -o out_fvec.exe $(FCFLAGS)
	$(CXX) views_eigen.cpp -o out_cpp_eigen.exe $(CXXFLAGS) -I$(EIGENROOT)
	$(CXX) views_blaze.cpp -o out_cpp_blaze.exe $(CXXFLAGS) -I$(BLAZEROOT)
	$(CXX) views_fastor.cpp -o out_cpp_fastor.exe $(CXXFLAGS) -I$(FASTORROOT) $(FASTOR_FLAGS)
	$(CXX) views_armadillo.cpp -o out_cpp_armadillo.exe $(CXXFLAGS) -I$(ARMAROOT)/include/ -L$(ARMAROOT)/lib $(ARMA_FLAGS)
	$(CXX) views_xtensor.cpp -o out_cpp_xtensor.exe $(CXXFLAGS) $(XTENSOR_INC) $(XTENSOR_FLAGS)

run:
# 	./out_c.exe $(N)
# 	./out_floops.exe $(N)
# 	./out_fvec.exe $(N)
	./out_cpp_eigen.exe $(N)
	./out_cpp_blaze.exe $(N)
	./out_cpp_fastor.exe $(N)
	./out_cpp_armadillo.exe $(N)
	./out_cpp_xtensor.exe $(N)

clean:
	rm -rf *.exe