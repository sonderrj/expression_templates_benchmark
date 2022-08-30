#define EIGEN_STACK_ALLOCATION_LIMIT 10000000000000
#define EIGEN_DONT_VECTORIZE
#include "helper.h"
#include "cmdline.h"
#include <Eigen/Core>
#include <string>
#include <iostream>

using namespace std;
using namespace Eigen;
using namespace bench_views;



template<typename T, int num>
void run_finite_difference() {

    T pi = 4*std::atan(1.0);
    T err = 2.;
    int iter = 0;

    Matrix<T,num,1> x;
    for (auto i=0; i<num; ++i) {
        x(i) = i*pi/(num-1);
    }

    // Matrix<T,num,num,RowMajor> u; u.setZero();
    Matrix<T,num,num> u; u.setZero();
    u.col(0) = x.array().sin();
    u.col(num-1) = x.array().sin()*std::exp(-pi);

    while (iter <100000 && err>1e-6) {
        Matrix<T,num,num> u_old = u;

        u(seq(1,num-2),seq(1,num-2)) =
        ((  u_old(seq(0,num-3),seq(1,num-2)) + u_old(seq(2,num-1),seq(1,num-2)) +
            u_old(seq(1,num-2),seq(0,num-3)) + u_old(seq(1,num-2),seq(2,num-1)) )*4.0 +
            u_old(seq(0,num-3),seq(0,num-3)) + u_old(seq(0,num-3),seq(2,num-1)) +
            u_old(seq(2,num-1),seq(0,num-3)) + u_old(seq(2,num-1),seq(2,num-1)) ) /20.0;
        // err = finite_difference_block_impl(u);
        // err = finite_difference_fblock_impl(u);
        err = (u-u_old).norm();
        // err = finite_difference_fseq_impl(u);
        iter++;
    }

    println(" Relative error is: ", err, '\n');
    println("Number of iterations: ", iter, '\n');
}



int main(int argc, char *argv[]) {

    cmdline::parser cmd_parser;
    cmd_parser.add<string>("precision", 0, "matrix element precision", true, "double");
    cmd_parser.add<int>("size", 0, "matrix size", true, 100);
    cmd_parser.parse_check(argc, argv);
    string precision = cmd_parser.get<string>("precision");
    int size = cmd_parser.get<int>("size");

    timer<double> t_j;
    t_j.tic();
    

    if (precision=="double") run_finite_difference<T,100>();
    if (N==150) run_finite_difference<T,150>();
    if (N==200) run_finite_difference<T,200>();
    //if (N==500) run_finite_difference<T,500>();
    //run_finite_difference<T, N>();

    t_j.toc();

    return 0;
}