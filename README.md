# Spack configuration files and scripts for use on machines at NREL

# Objective

The purpose of this repo is to provide scripts and recipes for the creation of a user environement.
This environment is built using spack.   
The set of configuration files and scripts provided in this repositery allow for the creation of a user environment containing the necessary compilers , tools , libraries and software. 
This repo is built on previous work by Jon Rood, Tim Kaiser and Chris Chang.
It is currently maintained by Walid Arsalane.  

# Spack configuration files and scripts

The user environement is built using a hirarchy of levels. 
- "base" is just a newer version of GCC to replace the system GCC (4.8.5 for Eagle), this allow the environemnt to be isolated from the system compiler.
- "utilities" are the latest set of utility programs that don't rely on MPI and are built using the base GCC.
- "compilers" are the latest set of compilers built using the base GCC.
- "mpi" are the latest mpi compilers built using the recently built compilers. 
- "libraries" are the latest math libraries and I/O packages built using the recently installed compilers amd Mpis.
- "software" are the latest set of generally larger programs and dependencies that rely on MPI.
- "binaries" are generally the binary downloads of Paraview and Visit.

The Spack hierarchy is linked in the following manner where each installation is based on other upstream Spack installations. 
"software" depends on "utilities", "compilers", "mpi" and "libraries". 
"libraries" depends on "utilities", "compilers" and "mpi".
"mpi" depends on "utilities" and "compilers".
"compilers" depends on "base" and "utilities".
"utilities" depends on "base".
This hierarchy allows Spack to point to packages it needs which are already built upstream. 
This hirarchy between each level can be shown in the following picture 
![environment dependency chain](edc.jpg)
A complete list of packages for each level is included in the file [packages_list.txt](packages_list.txt).
Currently there is no perfect way to advertise deprecation or addition, and evolution of these modules. 


# Use spack built environent 

Before we get into the commands to 

In order to use the installed modules you can run 

`source spack-configs/env.sh`

If `module avail` does not show the modules on Eagle, try removing the LMOD cache with `rm -rf ~/.lmod.d/.cache`

Also included in this directory is a recommended Spack configurations you can use to build your own packages on the machines supported at NREL. Once you have `SPACK_ROOT` set you can run `/nopt/nrel/ecom/hpacf/spack-configs/scripts/setup-spack.sh` which should copy the yaml files into your instance of Spack. Or you can copy the yaml files into your `${SPACK_ROOT}/etc` directory manually. `spack compilers` should then show you many available compilers. Source your Spack's `setup-env.sh` after you do the `module unuse ${MODULEPATH}` in your `.bashrc` so that your Spack instance will add its own module path to MODULEPATH. Remove `~/.spack/linux` if it exists and `spack compilers` doesn't show you the updated list of compilers. The `~/.spack` directory takes highest precendence in the Spack configuration.
