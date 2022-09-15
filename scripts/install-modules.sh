#!/bin/bash -l

# Script for installation of HPACF group related compilers, utilities, and software on Eagle and Rhodes.
# The idea of this script requires running each TYPE stage and manually intervening after stage to set
# up for the next stage by editing the yaml files used in the next stage.

#SBATCH -J build-modules
#SBATCH -o %x.o%j
#SBATCH -t 1-00:00:00
#SBATCH -N 1
#SBATCH -p standard
#SBATCH -A hpcapps

#TYPE=base
#TYPE=utilities
#TYPE=compilers
#TYPE=mpi
TYPE=libraries
#TYPE=software

DATE=08-22

set -e

# Function for printing and executing commands
cmd() {
  echo "+ $@";
  eval "$@";
}

printf "============================================================\n"
printf "$(date)\n"
printf "============================================================\n"
printf "Job is running on ${HOSTNAME}\n"
printf "============================================================\n"

# Find machine we're on
case "${NREL_CLUSTER}" in
  eagle)
    MACHINE=eagle
  ;;
esac
case "${NREL_CLUSTER}" in
  vermilion)
    MACHINE=vermilion
  ;;
esac
MYHOSTNAME=$(hostname -s)
case "${MYHOSTNAME}" in
  rhodes)
    MACHINE=rhodes
  ;;
esac

if [ "${MACHINE}" == 'eagle' ]; then
  BASE_DIR=/nopt/nrel/apps/base/warsalan/csso_08_22
elif [ "${MACHINE}" == 'vermilion' ]; then
  BASE_DIR=/nopt/nrel/apps/base/warsalan
elif [ "${MACHINE}" == 'rhodes' ]; then
  BASE_DIR=/opt
else
  printf "\nMachine name not recognized.\n"
  exit 1
fi

# Defining path to folder of interest 
INSTALL_DIR=${BASE_DIR}/${TYPE}/${DATE}
THIS_REPO_DIR=$(pwd)
License_PATH=${HOME}/save/license.lic

# Set spack location
export SPACK_ROOT=${INSTALL_DIR}/spack

# Set Compilers versions 
if [ "${TYPE}" == 'base' ]; then
  if [ "${MACHINE}" == 'eagle' ]; then
    GCC_COMPILER_VERSION=4.8.5
    CPU_OPT=linux-centos7-haswell
  elif [ "${MACHINE}" == 'vermilion' ]; then
    GCC_COMPILER_VERSION=9.4.0
    CPU_OPT=linux-rocky8-zen2
  elif [ "${MACHINE}" == 'rhodes' ]; then
    GCC_COMPILER_VERSION=4.8.5
    CPU_OPT=haswell
  fi
elif [[ "${TYPE}" == 'utilities' || "${TYPE}" == 'compilers' ]]; then
  if [ "${MACHINE}" == 'eagle' ]; then
  GCC_COMPILER_VERSION=8.4.0
    CPU_OPT=linux-centos7-skylake_avx512
  elif [ "${MACHINE}" == 'vermilion' ]; then
  GCC_COMPILER_VERSION=8.4.0
    CPU_OPT=linux-rocky8-zen2
  elif [ "${MACHINE}" == 'rhodes' ]; then
    CPU_OPT=broadwell
  fi
elif [[ "${TYPE}" == 'mpi' || "${TYPE}" == 'software' || "${TYPE}" == 'libraries' ]]; then
  if [ "${MACHINE}" == 'eagle' ]; then
  GCC_COMPILER_VERSION=10.1.0
    CPU_OPT=linux-centos7-skylake_avx512
  elif [ "${MACHINE}" == 'vermilion' ]; then
  GCC_COMPILER_VERSION=10.1.0
    CPU_OPT=linux-rocky8-zen2
  elif [ "${MACHINE}" == 'rhodes' ]; then
    CPU_OPT=broadwell
  fi
fi
GCC_COMPILER_MODULE=gcc/${GCC_COMPILER_VERSION}
INTEL_COMPILER_VERSION=2021.6.0
INTEL_COMPILER_MODULE=intel/${INTEL_COMPILER_VERSION}
CLANG_COMPILER_VERSION=14.0.6
CLANG_COMPILER_MODULE=llvm/${CLANG_COMPILER_VERSION}

# Loading modules 
printf "\nLoading modules...\n"
cmd "module purge"
cmd "module unuse ${MODULEPATH}"
if [ "${TYPE}" == 'utilities' ]; then
  cmd "module use ${BASE_DIR}/base/modules"
  cmd "module load gcc git python"
elif [ "${TYPE}" == 'compilers' ]; then
  cmd "module use ${BASE_DIR}/base/modules"
  cmd "module use ${BASE_DIR}/utilities/modules-08-22"
  cmd "module load gcc git python"
elif [ "${TYPE}" == 'mpi' ]; then
  cmd "module use ${BASE_DIR}/base/modules"
  cmd "module use ${BASE_DIR}/utilities/modules-08-22"
  cmd "module use ${BASE_DIR}/compilers/modules"
  cmd "module load gcc:10.1.0 intel-oneapi-compilers:2022.1.0  nvhpc:22.7 git python "
elif [[ "${TYPE}" == 'software' || "${TYPE}" == 'libraries' ]]; then
  cmd "module use ${BASE_DIR}/base/modules"
  cmd "module use ${BASE_DIR}/utilities/modules-08-22"
  cmd "module use ${BASE_DIR}/compilers/modules"
  cmd "module load gcc:10.1.0 git python intel-oneapi-compilers:2022.1.0"
fi

# Clone and setup spack
if [ ! -d "${INSTALL_DIR}" ]; then
  printf "============================================================\n"
  printf "Install directory doesn't exist.\n"
  printf "Creating everything from scratch...\n"
  printf "============================================================\n"

  printf "Creating top level install directory...\n"
  cmd "mkdir -p ${INSTALL_DIR}"
  printf "\nCloning Spack repo...\n"
  cmd "git clone -c feature.manyFiles=true https://github.com/spack/spack.git  ${SPACK_ROOT}"

  printf "\nConfiguring Spack...\n"
  cmd "cd ${THIS_REPO_DIR}/scripts && ./setup-spack.sh"
  cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/packages.yaml ${SPACK_ROOT}/etc/spack/"
  if [ "${TYPE}" == 'base' ]; then
  cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/${TYPE}/compilers.yaml ${SPACK_ROOT}/etc/spack/"
  fi
  cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/${TYPE}/modules.yaml ${SPACK_ROOT}/etc/spack/"
  cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/${TYPE}/upstreams.yaml ${SPACK_ROOT}/etc/spack/ || true"
  if [[ "${TYPE}" == 'base' || "${TYPE}" == 'utilities' ]]; then
    cmd "rm ${SPACK_ROOT}/etc/spack/upstreams.yaml || true"
  fi
  #if [ "${TYPE}" == 'base' ]; then
  #  cmd "rm -rf  /scratch/${USER}/.spack"
  #fi
  cmd "mkdir -p ${SPACK_ROOT}/etc/spack/licenses/intel"
  if [ -d "${License_PATH}" ]; then
    cmd "cp ${Licence_PATH} ${SPACK_ROOT}/etc/spack/licenses/intel/"
  fi
  if [[ "${TYPE}" != 'base' && "${TYPE}" != 'utilities' ]]; then
    cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/${TYPE}/packages.yaml ${SPACK_ROOT}/etc/spack/"
    cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/${TYPE}/packages.yaml ${SPACK_ROOT}/etc/spack/linux/"
  fi
  cmd "cp -r ${THIS_REPO_DIR}/repos ${SPACK_ROOT}/"
  cmd "export SPACK_DISABLE_LOCAL_CONFIG=true"
  cmd "export SPACK_USER_CACHE_PATH=${SPACK_ROOT}/.cache"
  cmd "source ${SPACK_ROOT}/share/spack/setup-env.sh"
  cmd "spack env create ${TYPE}"
  cmd "cp ${THIS_REPO_DIR}/configs/${MACHINE}/${TYPE}/spack.yaml ${SPACK_ROOT}/var/spack/environments/${TYPE}/spack.yaml"
  cmd "spack repo add ${SPACK_ROOT}/repos/external"

  printf "============================================================\n"
  printf "Done setting up install directory.\n"
  printf "============================================================\n"
else
  printf "\nLoading Spack...\n"
  cmd "export SPACK_DISABLE_LOCAL_CONFIG=true"
  cmd "export SPACK_USER_CACHE_PATH=${SPACK_ROOT}/.cache"
  cmd "source ${SPACK_ROOT}/share/spack/setup-env.sh"
fi


cmd "spack compiler find"
cmd "spack arch"

if [[ "${MACHINE}" == 'eagle' ||  "${MACHINE}" == 'vermilion' ]]; then
  printf "\nMaking and setting TMPDIR to disk...\n"
  cmd "mkdir -p /scratch/${USER}/.tmp"
  cmd "export TMPDIR=/scratch/${USER}/.tmp"
fi

printf "\nInstalling ${TYPE}...\n"

#cmd "spack config update"
cmd "spack bootstrap root /scratch/${USER}/.spack"
cmd "spack env activate ${TYPE}"
cmd "spack concretize --fresh --force"
cmd "spack  install "
wait

cmd "spack module tcl refresh --delete-tree -y"
printf "\nDone installing ${TYPE} at $(date).\n"

printf "\nCreating dated modules symlink...\n"

if [[ "${TYPE}" != 'software' && "${TYPE}" != 'mpi' && "${TYPE}" != 'libraries' ]]; then
  cmd "cd ${INSTALL_DIR}/.. && ln -sf ${DATE}/spack/share/spack/modules/${CPU_OPT}/gcc-${GCC_COMPILER_VERSION} modules-${DATE}  && cd -"
elif [[ "${TYPE}" == 'software' || "${TYPE}" == 'mpi' || "${TYPE}" == 'libraries' ]]; then
  #cmd "cd ${INSTALL_DIR}/.. && ln -sf ${DATE}/spack/share/spack/modules/${CPU_OPT}/gcc-${GCC_COMPILER_VERSION} modules-${DATE}-gcc-${GCC_COMPILER_VERSION} && cd -"
  #cmd "cd ${INSTALL_DIR}/.. && ln -sf ${DATE}/spack/share/spack/modules/${CPU_OPT}/intel-${INTEL_COMPILER_VERSION} modules-${DATE}-intel-${INTEL_COMPILER_VERSION} && cd -"
  if [  -d "${BASE_DIR}/${TYPE}/modules-${DATE}" ]; then
    cmd "rm -rf ${BASE_DIR}/${TYPE}/modules-${DATE}"
  fi
  if [ ! -d "${BASE_DIR}/${TYPE}/modules-${DATE}" ]; then
    cmd "mkdir ${BASE_DIR}/${TYPE}/modules-${DATE}"
  fi
  for i in ${BASE_DIR}/${TYPE}/${DATE}/spack/share/spack/modules/${CPU_OPT}/gcc-${GCC_COMPILER_VERSION}/*  ${BASE_DIR}/${TYPE}/${DATE}/spack/share/spack/modules/${CPU_OPT}/intel-${INTEL_COMPILER_VERSION}/* 
  do 
      cd ${BASE_DIR}/${TYPE}/modules-${DATE} &&  ln -sf $i $(basename $i)  
  done
fi

printf "\nSetting permissions...\n"

if [[ "${MACHINE}" == 'eagle' ||  "${MACHINE}" == 'vermilion' ]]; then
  if [[ "${TYPE}" != 'software' && "${TYPE}" != 'mpi' && "${TYPE}" != 'libraries' ]]; then
  # Need to create a blank .version for name/version splitting for lmod
    cd ${INSTALL_DIR}/spack/share/spack/modules/${CPU_OPT}/gcc-${GCC_COMPILER_VERSION} && find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I % touch %/.version
  elif [[ "${TYPE}" == 'software' || "${TYPE}" == 'mpi' || "${TYPE}" == 'libraries' ]]; then
    cd ${INSTALL_DIR}/spack/share/spack/modules/${CPU_OPT}/gcc-${GCC_COMPILER_VERSION} && find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I % touch %/.version
    cd ${INSTALL_DIR}/spack/share/spack/modules/${CPU_OPT}/intel-${INTEL_COMPILER_VERSION} && find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I % touch %/.version
  fi
#  cmd "nice -n 19 ionice -c 3 chmod -R a+rX,go-w ${INSTALL_DIR}"
#  cmd "nice -n 19 ionice -c 3 chgrp -R n-apps ${INSTALL_DIR}"
elif [ "${MACHINE}" == 'rhodes' ]; then
  cmd "nice -n 19 ionice -c 3 chgrp windsim /opt"
  cmd "nice -n 19 ionice -c 3 chgrp windsim /opt/${TYPE}"
  cmd "nice -n 19 ionice -c 3 chgrp -R windsim ${INSTALL_DIR}"
  cmd "nice -n 19 ionice -c 3 chmod a+rX,go-w /opt"
  cmd "nice -n 19 ionice -c 3 chmod a+rX,go-w /opt/${TYPE}"
  cmd "nice -n 19 ionice -c 3 chmod -R a+rX,go-w ${INSTALL_DIR}"
fi

printf "\n$(date)\n"
printf "\nDone!\n"


# Some other info:
# Edit software/compilers.yaml to point to all compilers this script installed in the compilers build phase
# Run makelocalrc for all PGI compilers (I think this sets a GCC to use as a frontend)
# I did something like:
# makelocalrc -gcc /nopt/nrel/ecom/hpacf/compilers/2019-05-08/spack/opt/spack/linux-centos7-x86_64/gcc-4.8.5/gcc-7.4.0-srw2azby5tn7wozbchryvj5ak3zlfz3r/bin/gcc -gpp /nopt/nrel/ecom/hpacf/compilers/2019-05-08/spack/opt/spack/linux-centos7-x86_64/gcc-4.8.5/gcc-7.4.0-srw2azby5tn7wozbchryvj5ak3zlfz3r/bin/g++ -g77 /nopt/nrel/ecom/hpacf/compilers/2019-05-08/spack/opt/spack/linux-centos7-x86_64/gcc-4.8.5/gcc-7.4.0-srw2azby5tn7wozbchryvj5ak3zlfz3r/bin/gfortran -x
# Add set PREOPTIONS=-D__GCC_ATOMIC_TEST_AND_SET_TRUEVAL=1; to localrc

# Other final manual customizations:
# - Rename necessary module files and set defaults
