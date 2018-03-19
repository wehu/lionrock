#!/bin/bash
set -e

ws=$1
top_module=$2
mode=$3
lib=$4
hdr=$5
dpi_hdr=$6
vf=$7

cd $ws
verilator --$mode -f $vf
cd obj_dir
make -j -f V$top_module.mk
make -j -f V$top_module.mk verilated.o
cd -
cp obj_dir/V${top_module}__ALL.a $lib -f
cp obj_dir/V${top_module}.h $hdr -f
if [ -e "obj_dir/V${top_module}__Dpi.h" ]; then
  cp obj_dir/V${top_module}__Dpi.h $dpi_hdr -f
else
  touch $dpi_hdr
fi
cp obj_dir/verilated.o verilated.o -f
