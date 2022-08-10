import simulator
import sys


f = open(sys.argv[1],'r')

sim_data = f.readlines()

s = simulator.Simulator()

# blank = ['halt' for _ in range(10)]
# blank.extend(sim_data)

# sim_data = blank

s.run_lines(sim_data)
s.status()
        # >>> import simulator
        # >>> # Defaults are verbose=False, mem=1000, pc=0
        # >>> s = simulator.Simulator()

        # >>> s.run_line('line of code')
        # >>> s.run_lines( ['line', 'line', 'line'] )

        # >>> s.status()                  # show register, data, and pc status

        # >>> s.get_register('$t0')       # manually retrieve a register value
        # >>> s.get_register('$8')
        # >>> s.get_register(9)

        #s.registers['$v0'] = 4      # manually set a register value
        # >>> s.data[4] = 42              # manually set a data value

        # >>> s.rerun()                   # reruns all previous instructions
        #s.instructions              # shows instructions in memory

        # >>> s.reset()                   # reset all registers, data, pc
print("reg_v0 is:  %d"%s.get_register('$v0'))

s.reset()
f.close()
