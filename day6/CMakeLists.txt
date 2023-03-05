add_mpi_executable(vmem vmem.cpp)

add_executable(gs_day6 gs.cpp)

add_executable(gs_omp1 gs_omp1.cpp)
target_compile_options(gs_omp1
PUBLIC
    $<$<CXX_COMPILER_ID:MSVC>:/openmp>
    $<$<CXX_COMPILER_ID:GNU>:-fopenmp>
    $<$<CXX_COMPILER_ID:Clang>:-fopenmp=libomp>
)

add_executable(gs_omp2 gs_omp2.cpp)
target_compile_options(gs_omp2
PUBLIC
    $<$<CXX_COMPILER_ID:MSVC>:/openmp>
    $<$<CXX_COMPILER_ID:GNU>:-fopenmp>
    $<$<CXX_COMPILER_ID:Clang>:-fopenmp=libomp>
)

add_executable(gs_hybrid gs_hybrid.cpp)
target_link_libraries(gs_hybrid
PUBLIC
    MPI::MPI_CXX
)
target_compile_features(gs_hybrid
PUBLIC
    cxx_std_11
)
target_compile_options(gs_hybrid
PUBLIC
    $<$<CXX_COMPILER_ID:MSVC>:/openmp>
    $<$<CXX_COMPILER_ID:GNU>:-fopenmp>
    $<$<CXX_COMPILER_ID:Clang>:-fopenmp=libomp>
)