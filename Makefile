# ---data display control zone---
## ---picture---
X_PLOT = "Eigen(openblas)" "Blaze(openblas)" # 加括号要用双引号引起来
EXECS =	./out_cpp_eigen_openblas_lapack.exe ./out_cpp_blaze_openblas_lapack.exe
Y_PLOT = "seconds in time" # 中间有空格也要用双引号引起来
TITLE = "view of performance"
PIC_FILENAME = test1.png
## ---可执行文件参数---
SIZE=100
NUMERICAL_VERSION = DOUBLE

# ---end data display control zone---

# ---compiler control zone---
## ---CXX---
CXX = clang++
## ---optimazition flags---
LANG_STD_FLAG = -std=c++14
O_FLAG = -O3
ULOOP_FLAG = -funroll-loops
INLINE_FLAG = -mllvm -inline-threshold=10000000
SIMD_FLAG = -ffp-contract=fast
OHTHER_FLAGS = -ftemplate-depth=10000000 -fconstexpr-depth=10000000 -foperator-arrow-depth=10000000
## ---compile target--- 
TARGET_FLAGS = --target=arm64-apple-macosx12.5.1 -mcpu=apple-m1
## ---debug or release---
DEBUG_OR_RELEASE = -DNDEBUG

CXXFLAGS = $(LANG_STD_FLAG) $(O_FLAG) $(ULOOP_FLAG) $(INLINE_FLAG) $(SIMD_FLAG) $(OHTHER_FLAGS) $(TARGET_FLAGS) $(DEBUG_OR_RELEASE)
# ---end compiler control zone---

# ---dependent lib zone---
EIGENROOT = /Users/sonderrj/Applications/eigen-3.4/include/eigen3
EIGEN_FLAGS = -DEIGEN_USE_BLAS -DEIGEN_USE_LAPACKE -lopenblas -llapack -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/lapack/include

BLAZEROOT = /Users/sonderrj/Applications/blaze-3.8.1/include
BLAZE_FLAGS = -DBLAZE_BLAS_MODE=1 -DBLAZE_USE_BLAS_MATRIX_VECTOR_MULTIPLICATION=1 -DBLAZE_USE_BLAS_MATRIX_MATRIX_MULTIPLICATION=1 -lopenblas -llapack -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/lapack/include

ARMAROOT = /Users/sonderrj/operating_space/armadillo-11.2.3
ARMA_FLAGS = -DUSE_NORM_BY_LAPACK -DARMA_NO_DEBUG -lopenblas -llapack -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/lapack/lib -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/lapack/include

XSIMDROOT = /Users/sonderrj/Applications/xsimd
XTLROOT = /Users/sonderrj/Applications/xtl
XTENSORROOT = /Users/sonderrj/Applications/xtensor
XTENSORBLASROOT = /Users/sonderrj/Applications/xtensor_blas
XTENSOR_FLAGS = -I$(XSIMDROOT)/include/ -I$(XTLROOT)/include/ -I$(XTENSORROOT)/include/ -I$(XTENSORBLASROOT)/include/
XTENSOR_FLAGS += -DXTENSOR_USE_XSIMD -lopenblas -llapack -DHAVE_BLAS=1 -L/opt/homebrew/opt/openblas/lib

FASTORROOT = /Users/sonderrj/Applications/Fastor/
FASTOR_FLAGS = -DFASTOR_NO_ALIAS -DFASTOR_DISPATCH_DIV_TO_MUL_EXPR
# ---end dependent lib zone---

compile:
#	$(CXX) views_eigen.cpp -o out_cpp_eigen_built_in.exe $(CXXFLAGS) -I$(EIGENROOT) -D$(NUMERICAL_VERSION)
	$(CXX) views_eigen.cpp -o out_cpp_eigen_openblas_lapack.exe $(CXXFLAGS) -I$(EIGENROOT) $(EIGEN_FLAGS) 
#	$(CXX) views_blaze.cpp -o out_cpp_blaze_openblas_lapack.exe $(CXXFLAGS) -I$(BLAZEROOT) $(BLAZE_FLAGS) -D$(NUMERICAL_VERSION)
#	$(CXX) views_fastor.cpp -o out_cpp_fastor_$(NUMERICAL_VERSION).exe $(CXXFLAGS) -I$(FASTORROOT) $(FASTOR_FLAGS) -D$(NUMERICAL_VERSION)
#	$(CXX) views_armadillo.cpp -o out_cpp_armadillo_openblas_lapack.exe $(CXXFLAGS) -I$(ARMAROOT)/include/ $(ARMA_FLAGS) -D$(NUMERICAL_VERSION)
#	$(CXX) views_xtensor.cpp -o out_cpp_xtensor_openblas_lapack_$(NUMERICAL_VERSION).exe $(CXXFLAGS) $(XTENSOR_INC) $(XTENSOR_FLAGS) -D$(NUMERICAL_VERSION)

plot:
	python3.9 ./plot_results.py  --xplot $(X_PLOT) --yplot $(Y_PLOT) --title $(TITLE) --size $(SIZE) --precision $(NUMERICAL_VERSION) --execs $(EXECS) --filename $(PIC_FILENAME)

clean:
	rm -rf *.exe