#include <cuda_runtime.h>
#include <iostream>

__global__ void addArrays(int *a, int *b, int *c, int n){
    //define a unique identifier for each thread 
    //each thread will compute one element of the array
      int index = threadIdx.x + blockIdx.x * blockDim.x; //ID of thread within a block, ID of thread within the grid, number of blocks in the grid
  
  // check if the thread index is within the bounds of the array
  if(index<n){
          c[index] = a[index] + b[index]; // add a and b element wise and save this to the result array
      }
}

int main(){
  const int N = 512; // number of elements in the array
  int h_a[N], h_b[N], h_c[N]; // initiallize the ararys 

  for(int i = 0; i<N; i++){ // populate the arrays
    h_a[i] = i;
    h_b[i] = i*2;
  }

  int *d_a, *d_b, *d_c;
  cudaMalloc(&d_a, sizeof(int)*N); //allocate memory on the device for array a
  cudaMalloc(&d_b, sizeof(int)*N); //allocate memory on the device for array b
  cudaMalloc(&d_c, sizeof(int)*N); //allocate memory on the device for array c (result array)

  //Transfer data from CPU to GPU
  cudaMemcpy(d_a, h_a, sizeof(int)*N, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, sizeof(int)*N, cudaMemcpyHostToDevice);

  //Launch the kernel on the GPU
  addArrays<<<N/256, 256>>>(d_a, d_b, d_c, N);

  cudaMemcpy(h_c, d_c, sizeof(int)*N, cudaMemcpyDeviceToHost); // copy the results stored in d_c on the GPU back to h_c on the CPU

  //Print the results (first 10)
  for(int i = 0; i<10; i++){
    std::cout << h_a[i] << "+" <<h_b[i]<< "=" << h_c[i]<<std::endl;
  }

  //Free the memory
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);
  return 0;
}
