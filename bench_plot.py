#!/usr/bin/env python

import sys
import os
import csv

import matplotlib.pyplot as plt


def read_file(path):
    fn = "%s/summary.csv" % path
    x, y = [], []
    with open(fn, 'r') as f:
        for line in csv.DictReader(f, skipinitialspace=True):
            assert int(line['failed']) == 0, "Failures are not tolerated"
            x.append(float(line['elapsed']))
            y.append(int(line['total']) / float(line['window']))
    return x, y


def main(paths):
    fig = plt.figure()
    plt.xlabel("Elapsed (s)")
    for path in paths:
        label = path.split("/")[-1]
        x, y = read_file(path)
        plt.plot(x, y, label=label, marker='x')
    plt.title(os.getenv("PLOT_TITLE", "").replace("\\n", "\n"))
    plt.legend(loc='best')
    plt.ylabel("Requests per second")
    plt.ylim(ymin=0)
    plt.show()

if __name__ == "__main__":
    main(sys.argv[1:])
