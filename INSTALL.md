This file describes the procedure to intall a software/application using Spack through this repo.
This repo uses levels in Spack to separate each type of application.

the levels are:

1- base: this layer is used to isolate the system compiler. 
we use `gcc/8.4.0` as a base compiler.
In some case the compute nodes dont have a c++ compiler or git.
in addtion to the compiler, we install git and wget in case they are not installed on the compute node. 
the base layer is intalled using a login node on eagle, since c++ nor git are available on the compute nodes. 

2- compilers: this layer contains most common compilers.
all compilers here are installed using the base layer compiler gcc/8.4.0.
the compilers include:
  - binutils
  - gcc@12.1.0
  - go@1.17.7
  - intel-oneapi-compilers@2022.1.0
  - llvm@14.0.0
  - cuda
  - nvhpc@22.7
  - aocc@3.2.0+license-agreed

In addition to all compilers, binutils is intalled to provide the necessary GNU binary tools Pgi is also of interest however it requires a manual download before installing with Spack. 

3- utilities: this layer contains the necessary utilities such as:
<table border="0">
 <tr>
    <td><b style="font-size:30px"></b></td>
    <td><b style="font-size:30px"></b></td>
 </tr>
 <tr>
    <td>
- anaconda3
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
- gnutls
- htop
- imagemagick
- libxml2
- likwid
- ninja
- mercurial
- makedepend
    </td>
    <td>
- patch
- pkg-config
- python@3.9.13
- python@3.10.6
- screen
- stow
- strace
- texinfo
- tmux
- tar
- unzip
- vim
- zsh
- ucx
- slurm
    </td>
 </tr>
</table>

4- mpi: this layer contains the most common mpi packages
- mpich, 
- openmpi 
- intel-mpi 

each of the mpi packges is installed using a specific compiler (gcc,intel)


5- libraries: this include math libraries and I/O libraries 
  - petsc ^mpi
  - slepc ^mpi 
  - adios ^mpi
  - hypre ^mpi
  - hdf5 ^mpi  
  - fftw ^mpi
  - openblas 
  - netlib-lapack
  - netlib-scalapack
 
the mpi used for the packages above are openmpi and intel-mpi.

6- software: this layer includes maths libraries and applications


## python modules 

as mentionned earlier, two instances of python will be installed python3.9 and python3.10.
for each one, pip will be used to install modules such as numpy scipy jupyter pandas and matplotlib.
Once the python module is loaded 
`module load python/{version}`

we need to install pip for that loaded version of python using 

`python -m ensurepip --default-pip`

we can use the following command to install the python modules

`python -m pip install --upgrade pip setuptools wheel numpy scipy matplotlib jupyter pandas`

In order to install mpi4py using pip, mpi needs to be loaded. 

other installed packages:
- tensorflow 
- torch




# install software:

## General information

For a list of packages available in Spack see the following website:
https://spack.readthedocs.io/en/latest/package_list.html#package-list



It is important to know the variants of each Spack package.
We can see variants of package by using `spack info <package>`.
an example of this command with netcdf-c is demonstrated below.


```bash
AutotoolsPackage:   netcdf-c

Description:
    NetCDF (network Common Data Form) is a set of software libraries and
    machine-independent data formats that support the creation, access, and
    sharing of array-oriented scientific data. This is the C distribution.

Homepage: https://www.unidata.ucar.edu/software/netcdf

Preferred version:  
    4.8.1      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz

Safe versions:  
    main       [git] https://github.com/Unidata/netcdf-c.git on branch main
    4.8.1      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz
    4.8.0      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.0.tar.gz
    4.7.4      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.7.4.tar.gz
    4.7.3      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.7.3.tar.gz
    4.7.2      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.7.2.tar.gz
    4.7.1      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.7.1.tar.gz
    4.7.0      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.7.0.tar.gz
    4.6.3      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.3.tar.gz
    4.6.2      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.2.tar.gz
    4.6.1      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.1.tar.gz
    4.6.0      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.0.tar.gz
    4.5.0      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.5.0.tar.gz
    4.4.1.1    https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.4.1.1.tar.gz
    4.4.1      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.4.1.tar.gz
    4.4.0      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.4.0.tar.gz
    4.3.3.1    https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.3.3.1.tar.gz
    4.3.3      https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.3.3.tar.gz

Deprecated versions:  
    None

Variants:
    Name [Default]           When    Allowed values    Description
    =====================    ====    ==============    =====================================

    dap [off]                --      on, off           Enable DAP support
    fsync [off]              --      on, off           Enable fsync support
    hdf4 [off]               --      on, off           Enable HDF4 support
    jna [off]                --      on, off           Enable JNA support
    mpi [on]                 --      on, off           Enable parallel I/O for netcdf-4
    parallel-netcdf [off]    --      on, off           Enable parallel I/O for classic files
    pic [on]                 --      on, off           Produce position-independent code
                                                       (for shared libs)
    shared [on]              --      on, off           Enable shared library

Build Dependencies:
    autoconf  curl       hdf   libtool  mpi              zlib
    automake  gnuconfig  hdf5  m4       parallel-netcdf

Link Dependencies:
    curl  hdf  hdf5  mpi  parallel-netcdf  zlib

Run Dependencies:
    None
```

`spack info` first defines the package and displays allow available versions and the preferred for installation.
You can specify a specific version to install by using `netcdf-c@<version>`
The variants are then displayed showing the ones used by default (with [on]) and the ones that can be used but are not set by default ([off]).
In this example `netcdf-c` is using mpi and pic by default.
In order to use any other variant we need to add `+<variant>`, i.e. `netcdf-c +dap+fsync...`
If we want to remove a default variant we need to add `~<variant>`, i.e. `netcdf-c ~mpi~pic` 

## Files to modify

There are num of important files that needs to be updated.  

### Software to install: `spack.yaml`

First `spack.yaml` which is located in `spack-config/configs/eagle/software`
This file will contain the list of applications to be installed. 
you can always specify the compiler of choice by using `%{compiler-name}%{compiler-version}`
and also specify the mpi of choice by using `^{mpi-name}@{mpi-version}`
as an example, if we wanted to install petsc using openmpi/4.1.1 and gcc/12.1.0, spack.yaml will look ike this 

```yaml
spack:
  specs:
  - petsc@4.7.4 +mpi~pic ^openmpi@4.1.1 %gcc@12.1.0  
  view: false
```

spack will automatically reuse any previously installed package from the previous layers.



### Compilers location: `compilers.yaml`

The compilers are defined in `compilers.yaml` which is located in `configs/eagle/software/`.
This file contains the path to all c, c++ and fortran compilers already installed.
when specifiying the compiler used for the installation of a package, we need to make sure it is already defined in `spack.yaml`.


### Installation script: `install-modules.sh` 

next we need to modify the file install-modules.sh which is located in spack-config/script/.
first thing to modify is the DATE. 
The date is used to create the installation folder and the modules folder. 
it also helps keep track of the installations order. 
The next important thing to modify is the INSTALL_DIR path.
This should the path where your installation will be located. 
as an example, for hpcapps members, a good installtion path would be:

`/nopt/nrel/apps/base/${USER}/${TYPE}/{DATE}`

once the two files are modified we can execute the following command to install the packages 
`./scripts/intall-modules.sh`

this will: 
- create the installation directory
- clone Spack
- copy all necessary files 
- load necessary modules 
- install packages 
- create module files for all packages 
- set permissions 

### Creation of custom packages 

Our definition of custom packages means any package or application not available in the package list on Spack documentation [website](https://spack.readthedocs.io/en/latest/package_list.html#package-list) or any package that we want to install using a tar ball. 
Thh first step is to create a folder that will contain all custom recipes and point Spack to it.
As an example the folder will be created under `$SPACK_ROOT/custom`.
the folder `custom` should contain 

1- packages

This contains subfolders with the name of any custom package we want to install.
Each subfolder contains a python file `package.py` which is the Spack recipe used for the installation. 

2- repo.yaml

This yaml file is used by Spack to recognize other Spack recipes location.
The yaml file looks like this 

```yaml
repo:
  namespace: custom
```  

The custom folder should like this 

```bash 
custom 
  repo.yaml
  packages 
    package_name_1
      package.py
    package_name_2
    package_name_3
    ...
```

In order to point Spack to the custom folder we use

`spack repo add $SPACK_ROOT/custom`

This adds the folder `custom` as another package repositery. 
The next step is to create the packge file. 
THis is done with the command 

`spack create <url>`

`<url>` is the link that contains the software repository.
The spack create command builds a new package from a template by taking the location of the package source code and using it to:
- Fetch the code.
- Create a package skeleton.
- Open the file up in your editor of choice

