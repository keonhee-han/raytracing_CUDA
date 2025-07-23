CUDA_PATH     ?= /usr/lib/cuda
HOST_COMPILER  = g++
NVCC           = /usr/bin/nvcc -ccbin $(HOST_COMPILER)

# select one of these for Debug vs. Release
NVCC_DBG       = -g -G
#NVCC_DBG       =

NVCCFLAGS      = $(NVCC_DBG) -m64
# For Ada Lovelace architecture
GENCODE_FLAGS = -gencode arch=compute_89,code=sm_89
# GENCODE_FLAGS  = -gencode arch=compute_60,code=sm_60

cudart: cudart.o
	$(NVCC) $(NVCCFLAGS) $(GENCODE_FLAGS) -o cudart cudart.o

cudart.o: main.cu
	$(NVCC) $(NVCCFLAGS) $(GENCODE_FLAGS) -o cudart.o -c main.cu

out.ppm: cudart
	rm -f out.ppm
	./cudart > out.ppm

out.jpg: out.ppm
	rm -f out.jpg
	ppmtojpeg out.ppm > out.jpg

profile_basic: cudart
	nvprof ./cudart > out.ppm

# NOTE: `nvprof` is deprecated for newer GPUs' architecture like Ada Lovelace. To properly profile for the GPUs, use NVIDIA Nsight compute as CLI command, `ncu`, which is direct replacement for `nvprof` for kernel-level profiling. For system-wide tracing and profiling, use Nsight-SYstems. Its CLI command is `nsys` - It helps you identify bottlenecks across CPU and GPU interactions, including API call overhead, kernel launch times, memory transfers, and CPU activity. It's excellent for understanding the overall application flow.
# Usage Example (CLI) : 
# `ncu --metrics achieved_occupancy,inst_executed,inst_fp_32,inst_fp_64,inst_integer ./cudart`
# `nsys profile -o my_report ./cudart`

# (deprecated) use nvprof --query-metrics
# nvprof --metrics achieved_occupancy,inst_executed,inst_fp_32,inst_fp_64,inst_integer ./cudart > out.ppm

profile_metrics: cudart
	ncu --metrics achieved_occupancy,inst_executed,inst_fp_32,inst_fp_64,inst_integer ./cudart > out.ppm

clean:
	rm -f cudart cudart.o out.ppm out.jpg
