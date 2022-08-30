#!/bin/bash

# Need TriBITS and Trilinos
git clone https://github.com/TriBITSPub/TriBITS.git TriBITS
cd TriBITS
git checkout 769f615fafb
export TRIBITS_BASE_DIR="${PWD}"
cd ..

git clone https://github.com/Trilinos/Trilinos.git Trilinos
# cd Trilinos
# git checkout 81e9581a3c5a
# cd ..

# Copied from Trilinos conda-feedstock (https://github.com/conda-forge/trilinos-feedstock)
mkdir -p build
cd build

if [ $(uname) == Darwin ]; then
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
fi

export MPI_FLAGS="--allow-run-as-root"
export SHARED_LIBS=OFF

if [ $(uname) == Linux ]; then
    export MPI_FLAGS="$MPI_FLAGS;-mca;plm;isolated"
    # The Linux.opts sets shared libs only for Linux
    export SHARED_LIBS=ON
fi

export MPICH_IGNORE_CXX_SEEK=OFF
if [ $(MPI_IMPL) != "openmpi" ]; then
    export MPICH_IGNORE_CXX_SEEK=ON
fi

# Collected from General.opts, sems-ppit-opt.opts, and Trilinos conda-feedstock
cmake \
  -D CMAKE_BUILD_TYPE:STRING=RELEASE \
  -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
  -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
  -D CMAKE_SKIP_RULE_DEPENDENCY:BOOL=ON \
  -D CMAKE_CXX_STANDARD:STRING=14 \
  -D CMAKE_FIND_NO_INSTALL_PREFIX:BOOL=ON \
  \
  -D BUILD_SHARED_LIBS:BOOL=$SHARED_LIBS \
  -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
  -D MPI_BASE_DIR:PATH=$PREFIX \
  -D MPI_EXEC:FILEPATH=$PREFIX/bin/mpiexec \
  -D MPICH_IGNORE_CXX_SEEK:BOOL=$MPICH_IGNORE_CXX_SEEK \
  \
  -D tcad-charon_TEST_CATEGORIES:STRING="HEAVY" \
  -D tcad-charon_VERBOSE_CONFIGURE:BOOL=OFF \
  \
  -D tcad-charon_ENABLE_PyTrilinos:BOOL=OFF \
  -D tcad-charon_ENABLE_Kokkos:BOOL=ON \
  -D tcad-charon_ENABLE_KokkosAlgorithms:BOOL=ON \
  -D tcad-charon_ENABLE_KokkosCore:BOOL=ON \
  -D tcad-charon_ENABLE_INSTALL_CMAKE_CONFIG_FILES:BOOL=ON \
  -D tcad-charon_ENABLE_CHECKED_STL:BOOL=OFF \
  -D tcad-charon_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
  -D tcad-charon_ENABLE_MueLu:BOOL=ON \
  -D tcad-charon_ENABLE_Stokhos:BOOL=OFF \
  -D tcad-charon_ENABLE_ROL:BOOL=OFF \
  -D tcad-charon_ENABLE_SECONDARY_TESTED_CODE:BOOL=OFF \
  -D tcad-charon_ENABLE_ALL_PACKAGES:BOOL=OFF \
  -D tcad-charon_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF \
  -D tcad-charon_ENABLE_SEACASEx1ex2v2:BOOL=OFF \
  -D tcad-charon_ENABLE_SEACASEx2ex1v2:BOOL=OFF \
  -D tcad-charon_ENABLE_SEACASExomatlab:BOOL=OFF \
  -D tcad-charon_ENABLE_Sacado:BOOL=ON \
  -D tcad-charon_ENABLE_AztecOO:BOOL=ON \
  -D tcad-charon_ENABLE_Ifpack:BOOL=ON \
  -D tcad-charon_ENABLE_Amesos2:BOOL=ON \
  -D tcad-charon_ENABLE_Ifpack2:BOOL=ON \
  -D tcad-charon_ENABLE_Tempus:BOOL=ON \
  -D tcad-charon_ENABLE_Zoltan2:BOOL=ON \
  -D tcad-charon_ENABLE_Xpetra:BOOL=ON \
  -D tcad-charon_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON \
  -D tcad-charon_ENABLE_STKUnit_test_utils:BOOL=OFF \
  -D tcad-charon_ENABLE_STKSearch:BOOL=OFF \
  -D tcad-charon_ENABLE_STKSearchUtil:BOOL=OFF \
  -D tcad-charon_ENABLE_STKUnit_tests:BOOL=OFF \
  -D tcad-charon_ENABLE_STKDoc_tests:BOOL=OFF \
  -D tcad-charon_ENABLE_STKExprEval:BOOL=OFF \
  -D tcad-charon_ENABLE_TESTS:BOOL=OFF \
  -D tcad-charon_ENABLE_EXAMPLES:BOOL=OFF \
  -D tcad-charon_ENABLE_DAKOTA_DRIVERS:BOOL=ON \
  -D tcad-charon_ENABLE_Epetra:BOOL=ON \
  -D tcad-charon_ENABLE_Charon:BOOL=ON \
  -D Charon_ENABLE_TESTS:BOOL=OFF \
  -D Charon_ENABLE_EXAMPLES:BOOL=ON \
  -D Charon_ENABLE_DEBUG:BOOL=OFF \
  \
  -D TPL_ENABLE_MPI:BOOL=ON \
  -D TPL_ENABLE_Matio:BOOL=OFF \
  -D TPL_ENABLE_X11:BOOL=OFF \
  -D TPL_ENABLE_HDF5:BOOL=ON \
  -D TPL_ENABLE_Boost:BOOL=ON \
  -D TPL_ENABLE_BoostLib:BOOL=ON \
  -D TPL_ENABLE_Netcdf:BOOL=ON \
  \
  -D AztecOO_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
  -D Intrepid2_ENABLE_DEBUG_INF_CHECK:BOOL=OFF \
  -D SEACASExodus_ENABLE_MPI:BOOL=OFF \
  -D Kokkos_ENABLE_SERIAL:BOOL=ON \
  -D Kokkos_ENABLE_OPENMP:BOOL=OFF \
  -D Kokkos_ENABLE_PTHREAD:BOOL=OFF \
  -D Kokkos_ENABLE_CUDA:BOOL=OFF \
  -D Panzer_ENABLE_TESTS:BOOL=OFF \
  -D EpetraExt_ENABLE_HDF5:BOOL=OFF \
  \
  -D GIT_EXECUTABLE:FILEPATH="$(which git)" \
  $SRC_DIR

# make -j $CPU_COUNT install
make -j install

# ctest -VV --output-on-failure -j${CPU_COUNT}

# Install charon Python files
export PYTHON_LIBS_DIR=$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')

# remove python2 versions
rm ${PREFIX}/lib/exodus2.py ${PREFIX}/lib/exomerge2.py

# move python3 versions to site-packages
mv \
  ${PREFIX}/lib/exodus3.py \
  ${PREFIX}/lib/exomerge3.py \
  ${PREFIX}/charonInterpreter \
  ${PREFIX}/Dakota \
  ${PYTHON_LIBS_DIR}
