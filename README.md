Ray Tracing in one Weekend in CUDA - refactored for Ada Lovelace
==================================

This is the forked version of CUDA code which is refactored according to the newer GPU architecture of Ada Lovelace. 

By Keonhee Han
28th July, 2025

How to use it - guidance
----------

Profiling
---------
To profile the kernels, please type `make profile_basic`. For detail profiling, type `make profile_metrics`

For further CLI command, please refer to the file named `Makefile`.

Original forked description
----------

This is yet another _Ray Tracing in One Weekend_ clone, but this time using CUDA instead of C++.

By Roger Allen
May, 2018

See the [Master Branch](https://github.com/rogerallen/raytracinginoneweekend) for more information.

Chapter 1
---------

This introduces the basic kernel launch mechanism & host/device memory management.  We are just creating an image on the GPU device and cudaMallocmanaged allows for sharing the framebuffer and automatically copying that buffer to & from the device.

I also added a timer to see how long it takes the GPU to do rendering.

Chapter 2
---------

Because CUDA is compatible with C++ and the vec3.h class will be used on both GPU & CPU, we add __host__ __device__ as a prefix to all methods.

Chapter 3
---------

Since the ray class is only used on the GPU, we will just add __device__ as a prefix to all methods.

The color function just needs a __device__ added since this is called from the render kernel.

Note, doing a straight translation from the original C++ will mean that any floating-point constants will be doubles and math on the GPU will be forced to be double-precision.  This will hurt our performance unnecessarily.  Special attention to floating point constants must be taken (e.g. 0.5 -> 0.5f).

Use the "profile_metrics" makefile target to count inst_fp_64 and be sure that is 0.

Chapter 4
---------

We only need to add a __device__ to the hit_sphere() call and use profile_metrics to watch for those floating-point constants.
