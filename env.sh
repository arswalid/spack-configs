#!/bin/bash

if [ -z ${MODULES_COMPILER+x} ]; then
  MODULES_COMPILER=gcc-8.4.0;
fi

if [ -z ${MODULES_DATE+x} ]; then
  MODULES_DATE=modules-08-22;
fi

base_path=/nopt/nrel/apps/base/warsalan/csso_08_22

gcc_compiler=gcc-10.1.0 
intel_compiler=intel-2021.6.0 

module purge
module unuse ${MODULEPATH}
#module use ${base_path}/base/modules
module use $base_path/utilities/${MODULES_DATE}
module use $base_path/compilers/modules 
#module use ${base_path}/mpi/${MODULES_DATE}-${gcc_compiler}
#module use ${base_path}/mpi/${MODULES_DATE}-${intel_compiler}
module use ${base_path}/mpi/modules_all
module use ${base_path}/libraries/${MODULES_DATE}
#module use ${base_path}/libraries/${MODULES_DATE}-${intel_compiler}
module use $base_path/software/${MODULES_DATE}/${MODULES_COMPILER}
module use $base_path/binaries/modules
