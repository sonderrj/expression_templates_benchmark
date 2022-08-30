from __future__ import print_function
import os, platform, sys, subprocess
import numpy as np
import matplotlib.pyplot as plt
import argparse
plt.rcdefaults()


# eigen/blaze/fastor/armadillo/xtensor

# double 100
# 0.13622926
# 0.1312754
# 0.115669
# 0.43718526
# 0.78880578

# double 150
# 0.80114001
# 0.6937311
# 0.712709050
# 2.299045
# 3.5829124

# double 200
# 2.406574
# 2.379607
# 2.19099700
# 6.522
# 11.1189

# single 100
# 0.0807457
# 0.28706351
# 0.0723373
# 0.41288866
# 0.76346416

# single 150
# 0.52801878
# 1.5160282
# 0.43575986
# 2.2451304
# 3.8300779

def run_command(command):
    p = subprocess.Popen(command,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT,
                         shell=True)
    #print(p.stdout.readlines())
    return p.stdout.readlines()

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--xplot",                     help = "x plot string", nargs = '+')
    parser.add_argument("--yplot",     type = str,     help = "y plot string")
    parser.add_argument("--title",     type = str,     help = "plot title")
    parser.add_argument("--size",      type = str,     help = "matrix size")
    parser.add_argument("--precision", type = str,     help = "numeracal precision")
    parser.add_argument("--execs",                     help = "execs string", nargs = '+')
    parser.add_argument("--filename",     type = str,     help = "picture filename")
    args = parser.parse_args()
    # args.delimiter.encode().decode('unicode_escape')

    print(args.precision)

    size = args.size
    num_iter = 1
    # execs = ["./out_cpp_eigen_built_in.exe", "./out_cpp_eigen_openblas_lapack.exe", "./out_cpp_blaze_openblas_lapack.exe", "./out_cpp_fastor.exe", "./out_cpp_armadillo_openblas_lapack.exe", "./out_cpp_xtensor_openblas_lapack.exe"]
    execs = args.execs
    performance = []
    for exe in execs:
        mean_elapsed = 0.
        for i in range(num_iter):
            for counter, line in enumerate(run_command(exe + " " + size)):
                if counter == 2:
                    line = str(line)
                    #print(line.split(" "))
                    sline = line.split(" ")[4]
                    elapsed = float(sline)
                    mean_elapsed += elapsed
        mean_elapsed /= float(num_iter)
        print(mean_elapsed, )
        performance.append(mean_elapsed)
    performance = np.array(performance)
    # return

    # with hand-written norms for arma and xtensor
    # performance = [0.13681212, 0.1312151, 0.115669, 0.43759528, 0.73877798] # double 100
    # performance = [0.80114001, 0.6937311, 0.712709050, 2.299045, 3.5829124] # double 150
    # performance = [2.406574, 2.379607, 2.19099700, 6.522, 11.1189] # double 200
    # performance = [2.406574, 2.379607, 2.19099700, 87.1129, 59.4571] # double 200 lapack

    # performance = [4.49, 6.73, 2.54, 3.45, 13.77] # compilation time

    objects = args.xplot
    y_pos = np.arange(len(objects))

    plt.bar(y_pos, performance, align='center', alpha=0.5)
    plt.xticks(y_pos, objects)
    plt.ylabel(args.yplot)
    plt.title(args.title)
    plt.grid(True)

    plt.savefig(args.filename)
    plt.show()


main()

