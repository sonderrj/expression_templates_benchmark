#include "helper.h"
#include <blaze/Blaze.h>
using namespace blaze;
using namespace bench_views;



template<typename T, int num>
void run_finite_difference() {

    T pi = 4*std::atan(1.0);
    T err = 2.;
    int iter = 0;

    StaticVector<T,num> x;
    for (auto i=0; i<num; ++i) {
        x[i] = i*pi/(num-1);
    }


    StaticMatrix<T,num,num> u(0);
    column(u,0) = sin(x);
    column(u,num-1) = sin(x)*std::exp(-pi);

    while (iter <100000 && err>1e-6) {
        StaticMatrix<T,num,num> u_old = u;
        submatrix(u, 1,1,num-2,num-2) =
        ((  submatrix(u_old,0,1,num-2,num-2) + submatrix(u_old,2,1,num-2,num-2) +
            submatrix(u_old,1,0,num-2,num-2) + submatrix(u_old,1,2,num-2,num-2) )*4.0 +
            submatrix(u_old,0,0,num-2,num-2) + submatrix(u_old,0,2,num-2,num-2) +
            submatrix(u_old,2,0,num-2,num-2) + submatrix(u_old,2,2,num-2,num-2) ) /20.0;

        err = norm(u-u_old);
        // err = finite_difference_fseq_impl(u);
        iter++;
    }

    println(" Relative error is: ", err, '\n');
    println("Number of iterations: ", iter, '\n');
}



int main(int argc, char *argv[]) {

#ifdef DOUBLE_VERSION
    using T = double;
#elif defined(FLOAT_VERSION)
    using T = float;
#endif
    int N;
    if (argc == 2) {
       N = atoi(argv[1]);
    }
    else {
       print("Usage: \n");
       print("      ./exe N \n", argv[0]);
       exit(-1);
    }


    timer<double> t_j;
    t_j.tic();
    if (N==100) run_finite_difference<T,100>();
    if (N==150) run_finite_difference<T,150>();
    if (N==200) run_finite_difference<T,200>();
    //if (N==1000) run_finite_difference<T,1000>();
    t_j.toc();

    return 0;
}