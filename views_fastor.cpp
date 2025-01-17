#include "helper.h"
#include <Fastor/Fastor.h>
using namespace Fastor;

template<typename T, size_t num>
void run_finite_difference() {

    T pi = 4*std::atan(1.0);
    T err = 2.;
    int iter = 0;

    Tensor<T,num> x;
    for (auto i=0; i<num; ++i) {
        x(i) = i*pi/(num-1);
    }

    Tensor<T,num,num> u; u.zeros();
    u(0,all) = sin(x);
    u(num-1,all) = sin(x)*std::exp(-pi);
    // u(fix<0>,all) = sin(x);
    // u(fix<num-1>,all) = sin(x)*std::exp(-pi);

    while (iter <100000 && err>1e-6) {

        Tensor<T,num,num> u_old = u;

        u(seq(1,last-1),seq(1,last-1)) =
        ((  u_old(seq(0,last-2),seq(1,last-1)) + u_old(seq(2,last),seq(1,last-1)) +
            u_old(seq(1,last-1),seq(0,last-2)) + u_old(seq(1,last-1),seq(2,last)) )*4.0 +
            u_old(seq(0,last-2),seq(0,last-2)) + u_old(seq(0,last-2),seq(2,last)) +
            u_old(seq(2,last),seq(0,last-2))   + u_old(seq(2,last),seq(2,last)) ) /20.0;
        
        err = norm(u-u_old);
        // err = finite_difference_fseq_impl(u);
        iter++;
    }

    bench_views::println(" Relative error is: ", err, '\n');
    bench_views::println("Number of iterations: ", iter, '\n');

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


    bench_views::timer<double> t_j;
    t_j.tic();
    if (N==100) run_finite_difference<T,100>();
    if (N==150) run_finite_difference<T,150>();
    if (N==200) run_finite_difference<T,200>();
    //if (N==1000) run_finite_difference<T,1000>();
    t_j.toc();

    return 0;
}