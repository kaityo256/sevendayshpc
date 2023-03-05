function(add_simd_executable name)
    add_executable(${name} ${ARGN})
    target_compile_features(${name}
    PUBLIC
        cxx_std_11
    )
    target_compile_options(simdcheck
    PUBLIC
        $<$<CXX_COMPILER_ID:MSVC>:/arch:AVX>
        $<$<CXX_COMPILER_ID:GNU>:-march=native>
        $<$<CXX_COMPILER_ID:Clang>:-march=native>
    )
endfunction()

function(add_simd_object name)
    add_library(${name}
    OBJECT
        ${ARGN}
    )
    target_compile_features(${name}
    PUBLIC
        cxx_std_11
    )
    target_compile_options(simdcheck
    PUBLIC
        $<$<CXX_COMPILER_ID:MSVC>:/arch:AVX>
        $<$<CXX_COMPILER_ID:GNU>:-march=native>
        $<$<CXX_COMPILER_ID:Clang>:-march=native>
    )
endfunction()

add_simd_executable(simdcheck simdcheck.cpp)
add_simd_executable(add add.cpp)
add_simd_executable(load load.cpp)
add_simd_executable(mul mul.cpp)
add_simd_executable(print print.cpp)

add_simd_object(func_simd func_simd.cpp)
add_simd_object(loadasm loadasm.cpp)
add_simd_object(setpd setpd.cpp)
