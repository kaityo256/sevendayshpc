cmake_minimum_required(VERSION 3.13)
project(sevendayshpc CXX)

find_package(MPI REQUIRED)

function(add_mpi_executable name)
    add_executable(${name} ${ARGN})
    target_link_libraries(${name}
    PUBLIC
        MPI::MPI_CXX
    )
    target_compile_features(${name}
    PUBLIC
        cxx_std_11
    )
endfunction()

add_subdirectory(examples/day1)
add_subdirectory(examples/day3)
add_subdirectory(examples/day4)
add_subdirectory(examples/day5)
add_subdirectory(examples/day6)
add_subdirectory(examples/day7)
