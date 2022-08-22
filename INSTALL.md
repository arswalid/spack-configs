This file describes the procedure to intall a software/application using spack through this repo.
This repo uses levels in spack to separate each type of application.

the levels are:
1- base: this layer is used to isolate the system compiler. 
we use gcc/8.4.0 as a base compiler.
In some case the compute nodes dont have a c++ compiler or git.
in addtion to the compiler, we install git and wget in case they are not installed on the compute node. 
the base layer is intalled using a login node on eagle, since c++ nor git are available on the compute nodes. 

2- compilers: this layer contains most common compilers.
all compilers here are installed using the base layer compiler gcc/8.4.0.
the compilers include:
  - gcc@12.1.0
  - go@1.17.7
  - intel-oneapi-compilers@2022.1.0
  - llvm@14.0.0
  - cuda
In addition to all compilers, binutils is intalled to provide the necessary GNU binary tools 
Pgi is also of interest however it requires a manual download before installing with spack. 

3- utilities: this layer contains the necessary utilities such as:
  - bc
  - bison
  - bzip2
  - cmake
  - cppcheck
  - curl
  - flex@2.6.3
  - ffmpeg
  - emacs
  - gdb
  - gnuplot+wx 
  - gnutls
  - htop
  - imagemagick 
  - libxml2
  - likwid
  - ninja
  - mercurial
  - makedepend
  - patch
  - pkg-config
  - python@3.9
  - python@3.10
  - rsync
  - screen
  - stow
  - strace
  - texinfo
  - texlive 
  - tmux
  - unzip
  - vim
  - zsh
  - ucx
  - slurm

4- mpi: this layer contains the most common mpi packages
- mpich, openmpi, intel-mpi, mpt 
each of the mpi packges is installed using a specific compiler (gcc,intel,clang,cuda)


5- software: this layer includes maths libraries and applications


## python modules 

as mentionned earlier, two instances of python will be installed python3.9 and python3.10.
for each one, pip will be used to install modules such as numpy scipy jupyter pandas and matplotlib.
Once the python module is loaded 
`module load python/{version}`

we can use the following command to install the python modules

`python -m pip install --upgrade pip setuptools wheel numpy scipy matplotlib jupyter pandas`

In order to install mpi4py using pip, mpi needs to be loaded. 



## install software:
There are num of important files that needs to be updated.  

First spack.yaml which is located in spack-config/configs/eagle/software
This file will contain the list of applications to be installed. 
you can always specify the compiler of choice by using `%{compiler-name}%{compiler-version}`
and also specify the mpi of choice by using `^{mpi-name}@{mpi-version}`
as an example, if we wanted to install petsc using openmpi/4.1.1 and gcc/12.1.0, spack.yaml will look ike this 

```
spack:
  specs:
  - petsc ^openmpi@4.1.1 %gcc@12.1.0  
  view: false
```

spack will automatically reuse any previously installed package from the previous layers.

next we need to modify the file install-modules.sh which is located in spack-config/script/.
first thing to modify is the DATE. 
The date is used to create the installation folder and the modules folder. 
it also helps keep track of the installations order. 
The next important thing to modify is the INSTALL_DIR path.
This should the path where your installation will be located. 
as an example, for hpcapps members, a good installtion path would be:
/nopt/nrel/apps/base/${USER}/${TYPE}/{DATE}

once the two files are modified we can execute the following command to install the packages 
`./scripts/intall-modules.sh`

this will: 
- create the installation directory
- clone spack
- copy all necessary files 
- load necessary modules 
- install packages 
- create module files for all packages 
- set permissions 

