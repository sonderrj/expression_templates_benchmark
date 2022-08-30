#include "helper.h"
#include <armadillo>
using namespace arma;
using namespace bench_views;


template<typename T, int num>
void run_finite_difference() {

    T pi = 4*std::atan(1.0);
    T err = 2.;
    int iter = 0;

    // vec::fixed<num> x;
    typename Col<T>::template fixed<num> x;
    for (auto i=0; i<num; ++i) {
        x(i) = i*pi/(num-1);
    }

    // mat::fixed<num,num> u; u.fill(T(0));
    typename Mat<T>::template fixed<num,num> u;
    u.fill(T(0));
    u.col(0) = sin(x);
    u.col(num-1) = sin(x)*std::exp(-pi);
    asm("#BEGINN");
    while (iter <100000 && err>1e-6) {
        typename Mat<T>::template fixed<num,num> u_old = u;
        u(span(1,num-2),span(1,num-2)) =
        ((  u_old(span(0,num-3),span(1,num-2)) + u_old(span(2,num-1),span(1,num-2)) +
            u_old(span(1,num-2),span(0,num-3)) + u_old(span(1,num-2),span(2,num-1)) )*4.0 +
            u_old(span(0,num-3),span(0,num-3)) + u_old(span(0,num-3),span(2,num-1)) +
            u_old(span(2,num-1),span(0,num-3)) + u_old(span(2,num-1),span(2,num-1)) ) /20.0;
#ifdef USE_NORM_BY_LAPACK
        err = norm(u - u_old);
#elif defined(USE_NORM_BY_MYSELF) 
        err = 0.;
        for (auto i=0; i<num; ++i) {
            for (auto j=0; j<num; ++j) {
                const auto tmp = u(j,i) - u_old(j,i);
                err += tmp*tmp;
            }
        }
        err = std::sqrt(err);
#endif
        iter++;
    }
    asm("#ENDD");

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