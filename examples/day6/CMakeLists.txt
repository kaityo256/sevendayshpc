add_mpi_executable(vmem vmem.cpp)

add_executable(gs_day6 gs.cpp)

find_package(OpenMP REQUIRED)

add_executable(gs_omp1 gs_omp1.cpp)
target_link_libraries(gs_omp1
PUBLIC
    OpenMP::OpenMP_CXX
)

add_executable(gs_omp2 gs_omp2.cpp)
target_link_libraries(gs_omp2
PUBLIC
    OpenMP::OpenMP_CXX
)

add_executable(gs_hybrid gs_hybrid.cpp)
target_link_libraries(gs_hybrid
PUBLIC
    MPI::MPI_CXX
    OpenMP::OpenMP_CXX
)
target_compile_features(gs_hybrid
PUBLIC
    cxx_std_11
)