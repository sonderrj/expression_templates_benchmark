#include "helper.h"
#include "cmdline.h"
#include <xsimd/xsimd.hpp>
#include <xtensor/xtensor.hpp>
#include <xtensor/xfixed.hpp>
#include <xtensor/xview.hpp>
#include <xtensor/xnorm.hpp>
#include <xtensor-blas/xlinalg.hpp>
#include <iostream>

using namespace std;
using namespace bench_views;

#define USE_DEFAULT 0


template<typename T, int num>
void run_finite_difference() {

    T pi = 4*std::atan(1.0);
    T err = 2.;
    int iter = 0;

    xt::xtensor_fixed<T, xt::xshape<num>> x;
    for (auto i=0; i<num; ++i) {
        x[i] = i*pi/(num-1);
    }

    xt::xtensor_fixed<T, xt::xshape<num,num>> u;
    u = xt::zeros<T>({num,num});
    xt::col(u,0) = xt::sin(x);
    xt::col(u,num-1) = sin(x)*std::exp(-pi);
    // asm("#BEGINN");
    while (iter <100000 && err>1e-6) {
        using xt::view;
        using xt::range;

        xt::xtensor_fixed<T, xt::xshape<num,num>> u_old = u;

        view(u,range(1,num-1),range(1,num-1)) =
            ((  view(u_old,range(0,num-2),range(1,num-1)) + view(u_old,range(2,num-0),range(1,num-1)) +
                view(u_old,range(1,num-1),range(0,num-2)) + view(u_old,range(1,num-1),range(2,num-0)) )*4.0 +
                view(u_old,range(0,num-2),range(0,num-2)) + view(u_old,range(0,num-2),range(2,num-0)) +
                view(u_old,range(2,num-0),range(0,num-2)) + view(u_old,range(2,num-0),range(2,num-0)) ) /20.0;

        err = xt::linalg::norm(u-u_old);
        iter++;
    }
    // asm("#ENDD");
    // println(" Relative error is: ", err, '\n');
    // println("Number of iterations: ", iter, '\n');
}


int main(int argc, char *argv[]) {

// #ifdef DOUBLE_VERSION
//     using T = double;
// #elif defined(FLOAT_VERSION)
//     using T = float;
// #endif
//     int N;
//     if (argc == 2) {
//        N = atoi(argv[1]);
//     }
//     else {
//        print("Usage: \n");
//        print("      ./exe N \n", argv[0]);
//        exit(-1);
//     }
    cmdline::parser cmd_parser;
    cmd_parser.add<string>("precision", 0, "matrix element precision", true, "double");
    cmd_parser.add<int>("size", 0, "matrix size", true, 100);
    cmd_parser.parse_check(argc, argv);

    cout << "precision:" << cmd_parser.get<string>("precision") <<
         endl << "matrix size:" << cmd_parser.get<int>("size");

    // timer<double> t_j;
    // t_j.tic();
    // if (N==100) run_finite_difference<T,100>();
    // if (N==150) run_finite_difference<T,150>();
    // if (N==200) run_finite_difference<T,200>();
    // //if (N==1000) run_finite_difference<T,1000>();
    // t_j.toc();

    return 0;
}