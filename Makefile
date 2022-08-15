N=100
NUMERICAL_VERSION = FLOAT_VERSION

CXX = clang++
OPT = -O3
INC = -I.
CCFLAGS = -Ofast -march=native -funroll-loops -DNDEBUG -fwhole-program #-flto
FCFLAGS = -Ofast -march=native -funroll-loops -DNDEBUG -fwhole-program #-flto
CXXFLAGS = -std=c++14 $(OPT) -march=native -funroll-loops -DNDEBUG  $(INC)

# INCLUDE PATHS AND PACKAGE SPECIFIC FLAGS
# ------------------------------------------------------------------------------------ #
EIGENROOT = /Users/sonderrj/Applications/eigen-3.4/include/eigen3
EIGEN_FLAGS = -DEIGEN_USE_BLAS -DEIGEN_USE_LAPACKE -lopenblas -llapack -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/lapack/include

BLAZEROOT = /Users/sonderrj/Applications/blaze-3.8.1/include
BLAZE_FLAGS = -DBLAZE_BLAS_MODE=1 -DBLAZE_USE_BLAS_MATRIX_VECTOR_MULTIPLICATION=1 -DBLAZE_USE_BLAS_MATRIX_MATRIX_MULTIPLICATION=1 -lopenblas -llapack -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/lapack/include

ARMAROOT = /Users/sonderrj/operating_space/armadillo-11.2.3
# ARMA_FLAGS = -DARMA_NO_DEBUG -lblas -llapack
ARMA_FLAGS = -DARMA_NO_DEBUG -lopenblas -llapack -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/lapack/include

XSIMDROOT = /Users/sonderrj/Applications/xsimd
XTLROOT = /Users/sonderrj/Applications/xtl
XTENSORROOT = /Users/sonderrj/Applications/xtensor
XTENSORBLASROOT = /Users/sonderrj/Applications/xtensor_blas
XTENSOR_FLAGS = -I$(XSIMDROOT)/include/ -I$(XTLROOT)/include/ -I$(XTENSORROOT)/include/ -I$(XTENSORBLASROOT)/include/
XTENSOR_FLAGS += -DXTENSOR_USE_XSIMD -lopenblas -llapack -DHAVE_BLAS=1 -L/opt/homebrew/opt/openblas/lib

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
	$(CXX) views_eigen.cpp -o out_cpp_eigen_built_in_$(NUMERICAL_VERSION).exe $(CXXFLAGS) -I$(EIGENROOT) -D$(NUMERICAL_VERSION)
	$(CXX) views_eigen.cpp -o out_cpp_eigen_openblas_lapack_$(NUMERICAL_VERSION).exe $(CXXFLAGS) -I$(EIGENROOT) $(EIGEN_FLAGS) -D$(NUMERICAL_VERSION)
	$(CXX) views_blaze.cpp -o out_cpp_blaze_openblas_lapack_$(NUMERICAL_VERSION).exe $(CXXFLAGS) -I$(BLAZEROOT) $(BLAZE_FLAGS) -D$(NUMERICAL_VERSION)
	$(CXX) views_fastor.cpp -o out_cpp_fastor_$(NUMERICAL_VERSION).exe $(CXXFLAGS) -I$(FASTORROOT) $(FASTOR_FLAGS) -D$(NUMERICAL_VERSION)
	$(CXX) views_armadillo.cpp -o out_cpp_armadillo_openblas_lapack_$(NUMERICAL_VERSION).exe $(CXXFLAGS) -I$(ARMAROOT)/include/ $(ARMA_FLAGS) -D$(NUMERICAL_VERSION)
	$(CXX) views_xtensor.cpp -o out_cpp_xtensor_openblas_lapack_$(NUMERICAL_VERSION).exe $(CXXFLAGS) $(XTENSOR_INC) $(XTENSOR_FLAGS) -D$(NUMERICAL_VERSION)

run:
# 	./out_c.exe $(N)
# 	./out_floops.exe $(N)
# 	./out_fvec.exe $(N)
	./out_cpp_eigen_built_in_$(NUMERICAL_VERSION).exe $(N)
	./out_cpp_eigen_openblas_lapack_$(NUMERICAL_VERSION).exe $(N)
	./out_cpp_blaze_openblas_lapack_$(NUMERICAL_VERSION).exe $(N)
	./out_cpp_fastor_$(NUMERICAL_VERSION).exe $(N)
	./out_cpp_armadillo_openblas_lapack_$(NUMERICAL_VERSION).exe $(N)
	./out_cpp_xtensor_openblas_lapack_$(NUMERICAL_VERSION).exe $(N)

clean:
	rm -rf *.exe