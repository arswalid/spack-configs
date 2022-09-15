import reframe as rfm
import reframe.utility.sanity as sn
from reframe.core.backends import getlauncher


@rfm.simple_test
class Mpi4py_test(rfm.RunOnlyRegressionTest):
    descr = 'python mpi4py Test'
    valid_systems = ['*']
    #Set whether you would like to test intelmpi, openmpi, or both.
    valid_prog_environs = ['openmpi']
    python_vers = parameter(['3.9','3.10'])
    num_nodes_to_run = parameter([1])
    executable = 'python' 
    tests = parameter(range(11))
    #scripts_list = parameter(['${script[0]}'])
    tags = {'benchmark','hpgmg'}

    @run_after('setup')
    def set_launcher(self):
        self.job.launcher = getlauncher('mpirun')()

    @run_after('init')
    def set_exec_opts(self):
        self.executable_opts = ['${script['+str(self.tests)+']}']

    @run_before('run')
    def set_num_tasks(self):
        if self.current_system.name == 'eagle':
               self.num_tasks_per_node = 16
               self.num_tasks = self.num_tasks_per_node*self.num_nodes_to_run
    
    @sanity_function
    def assert_solution(self):
        return  sn.assert_found(r'Done!', self.stdout)
    
    @run_before('run')
    def set_modules(self):
        if self.current_system.name == 'eagle':
            self.prerun_cmds+=['source /nopt/nrel/apps/base/warsalan/csso_08_22/env.sh']
            self.prerun_cmds+= ['script=()']
            self.prerun_cmds+= ['for f in /nopt/nrel/apps/base/warsalan/csso_08_22/spack-configs/tests/python_modules/mpi4py/tests_ready/*;do script+=($f);done']
            if self.python_vers  == '3.9':
                self.prerun_cmds+=  ['module purge']
                self.prerun_cmds+=  ['module load python:3.10.6']
                self.prerun_cmds+=  ['module load openmpi:4.1.4-gcc']
            if self.python_vers  == '3.10':
                self.prerun_cmds+=  ['module purge']
                self.prerun_cmds+=  ['module load python:3.9.13']
                self.prerun_cmds+=  ['module load openmpi:4.1.4-gcc']


    
    #@performance_function('DOF/s', perf_key='performance')
    #def extract_performance(self):
    #    bw_array = sn.extractall(r'DOF/s=(.*)', self.stdout, 1, str)
    #    bw_str = str(bw_array[0]).split()[0]
    #    bw_val = float(bw_str)
