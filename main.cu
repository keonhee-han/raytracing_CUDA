#include "ray.h"
#include "vec3.h"
#include <iostream>
#include <time.h>

/* CUDA API checking call : `cudaError_t` enum section of
 * https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__TYPES.html */
#define checkCudaErrors(val) check_cuda((val), #val, __FILE__, __LINE__)

void check_cuda(cudaError_t result, char const *const func,
                const char *const file, int const line) {
  if (result) {
    std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at "
              << file << ":" << line << " '" << func << "' \n";
    // Make sure we call CUDA Device Reset before exiting
    cudaDeviceReset();
    exit(99);
  }
}

__device__ bool hit_sphere(const vec3 &center, float radius, const ray &r) {
  vec3 oc = r.origin() - center;
  float a = dot(r.direction(), r.direction());
  float b = 2.0f * dot(oc, r.direction());
  float c = dot(oc, oc) - radius * radius;
  float discriminant = b * b - 4.0f * a * c;
  return (discriminant > 0.0f);
}

__device__ vec3 color(const ray &r) {
  if (hit_sphere(vec3(0, 0, -1), 0.5, r))
    return vec3(1, 0, 0);
  vec3 unit_direction = unit_vector(r.direction());
  float t = 0.5f * (unit_direction.y() + 1.0f);
  return (1.0f - t) * vec3(1.0, 1.0, 1.0) + t * vec3(0.5, 0.7, 1.0);
}

/* Writing CUDA kernel to render the image */
/**
 * @brief CUDA kernel to render the image.
 *
 * This kernel calculates the color for each pixel in the image and writes it to
 * the frame buffer. The kernel uses thread and block indices to determine the
 * pixel coordinates.
 *
 * @param fb      Pointer to the frame buffer (output).
 * @param max_x   Width of the image.
 * @param max_y   Height of the image.
 */
__global__ void render(vec3 *fb, int max_x, int max_y, vec3 lower_left_corner,
                       vec3 horizontal, vec3 vertical, vec3 origin) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  int j = threadIdx.y + blockIdx.y * blockDim.y;
  if ((i >= max_x) || (j >= max_y))
    return; // return null for out of image resolution

  // `j * max_x`:  This calculates the offset to the beginning of the current
  // row (y-coordinate).  It multiplies the row number `j` by the image width
  // `max_x` to get the number of pixels in the rows above the current row.
  // int pixel_index = j * max_x * 3 + i * 3;
  int pixel_index = j * max_x + i;
  // Normalzing the RGB values into the range [0,1] by image width and height,
  // `max_x` and `max_y`
  float u = float(i) / float(max_x);
  float v = float(j) / float(max_y);
  ray r(origin, lower_left_corner + u * horizontal + v * vertical);
  // ray r(origin, lower_left_corner + horizontal + vertical);
  fb[pixel_index] = color(r);
}

int main() {
  // initializing variables for thread size (tx, ty) and image resolution (nx,
  // ny)
  int nx = 1200;
  int ny = 600;
  int tx = 8;
  int ty = 8;

  std::cerr << "Rendering a " << nx << "x" << ny << " image ";
  std::cerr << "in " << tx << "x" << ty << " blocks. \n";

  int num_pixels = nx * ny;
  size_t fb_size = num_pixels * sizeof(vec3);

  // allocate Frame Buffer (FB)
  vec3 *fb;
  checkCudaErrors(cudaMallocManaged((void **)&fb, fb_size));

  // start timer
  clock_t start, stop;
  start = clock();

  // Render our buffer
  dim3 blocks(nx / tx + 1, ny / ty + 1);
  dim3 threads(tx, ty);
  // y-axis go up, the x-axis to the right, and the negative z-axis pointing in
  // the viewing direction. (This is commonly referred to as right-handed
  // coordinates.)
  render<<<blocks, threads>>>(fb, nx, ny, vec3(-2.0, -1.0, -1.0),
                              vec3(4.0, 0.0, 0.0), vec3(0.0, 2.0, 0.0),
                              vec3(0.0, 0.0, 0.0));
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaDeviceSynchronize());

  // computation time check
  stop = clock();
  double timer_seconds = (static_cast<double>(stop - start)) / CLOCKS_PER_SEC;
  std::cerr << "took " << timer_seconds << " seconds. \n";

  // Output FB as Image - Back on the host, after the `cudaDeviceSynchronize` we
  // can access the frame buffer on the CPU host to output the image to stdout
  std::cout << "P3\n" << nx << " " << ny << "\n255\n";
  for (int j = ny - 1; j >= 0; j--) {
    for (int i = 0; i < nx; i++) {
      // size_t pixel_index = j * 3 * nx + i * 3;
      size_t pixel_index = j * nx + i;
      // float r = fb[pixel_index + 0];
      // float g = fb[pixel_index + 1];
      // float b = fb[pixel_index + 2];
      int ir = int(255.99 * fb[pixel_index].r());
      int ig = int(255.99 * fb[pixel_index].g());
      int ib = int(255.99 * fb[pixel_index].b());
      std::cout << ir << " " << ig << " " << ib << "\n";
    }
  }

  checkCudaErrors(cudaFree(fb));
}
