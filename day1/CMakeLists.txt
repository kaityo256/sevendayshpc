add_mpi_executable(hello hello.cpp)
add_mpi_executable(rank rank.cpp)
add_mpi_executable(rank_stream rank_stream.cpp)

if (NOT WIN32)
    add_mpi_executable(gdb_mpi gdb_mpi.cpp)
endif()