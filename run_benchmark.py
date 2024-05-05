import os
import time

# Function to execute sysbench and measure execution time
def execute_benchmark(command):
    start_time = time.time()
    os.system(command)
    end_time = time.time()
    total_time = end_time - start_time
    return total_time

# CPU benchmark
cpu_time = execute_benchmark('sysbench cpu run > cpu_output.txt')
print("Time to execute CPU benchmark: \t\t{:.2f} seconds".format(cpu_time))

# Memory benchmark
memory_time = execute_benchmark('sysbench memory run > memory_output.txt')
print("Time to execute memory benchmark: \t\t{:.2f} seconds".format(memory_time))

# File I/O benchmark
fileio_time = execute_benchmark('sysbench fileio --file-test-mode=seqwr run > fileio_output.txt')
print("Time to execute file I/O benchmark: \t\t{:.2f} seconds".format(fileio_time))
# Total execution time
total_time = cpu_time + memory_time + fileio_time
print("Total execution time: \t\t{:.2f} seconds".format(total_time))
