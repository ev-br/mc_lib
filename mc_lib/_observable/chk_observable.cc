#include<iostream>
#include "observable.h"

/*
 * A trivial implement for troubleshooting borked C++ toolchains
 * (looking at you, MacOS).
 */

int main()
{

mc_stats::ScalarObservable<double> obs;

obs << 1.0 ;
obs << 2.0 ;
obs << 3.0;

std::cout << obs.mean() << "\n";

}

