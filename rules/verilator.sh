#!/bin/bash
set -e

ws=$1
top_module=$2
mode=$3
lib=$4
hdr=$5
dpi_hdr=$6
vf=$7

WORKSPACE_ROOT=`pwd`

export VERILATOR_ROOT=$WORKSPACE_ROOT/external/verilator
export SYSTEMC_INCLUDE=$WORKSPACE_ROOT/external/systemc/include
export SYSTEMC_LIBDIR=$WORKSPACE_ROOT/external/systemc/lib-linux

cd $ws

sed -i "s|\$WORKSPACE_ROOT|$WORKSPACE_ROOT|g" $vf

$VERILATOR_ROOT/bin/verilator --$mode -f $vf
cd obj_dir
make -j -f V$top_module.mk USER_CPPFLAGS="-DSC_CPLUSPLUS=199711L"
make -j -f V$top_module.mk verilated.o USER_CPPFLAGS="-DSC_CPLUSPLUS=199711L"
cd -
cp obj_dir/V${top_module}__ALL.a $lib -f
cp obj_dir/V${top_module}.h $hdr -f
if [ -e "obj_dir/V${top_module}__Dpi.h" ]; then
  cp obj_dir/V${top_module}__Dpi.h $dpi_hdr -f
else
  touch $dpi_hdr
fi
cp obj_dir/verilated.o verilated.o -f
