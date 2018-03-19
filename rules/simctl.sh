#!/bin/bash
set -e

vendor=$1
ws=$2
top_module=$3
output=$4
vf=$5

WORKSPACE_ROOT=`pwd`

export VERILATOR_ROOT=$WORKSPACE_ROOT/external/verilator
export SYSTEMC_INCLUDE=$WORKSPACE_ROOT/external/systemc/include
export SYSTEMC_LIBDIR=$WORKSPACE_ROOT/external/systemc/lib-linux

cd $ws

sed -i "s|\$WORKSPACE_ROOT|$WORKSPACE_ROOT|g" $vf

if [ "$vendor" == "vcs" ]; then
  vcs -DVCS -f $vf -o $output
elif [ "$vendor" == "verilator" ]; then
  cat <<EOF >$top_module.cpp
      #include "V$top_module.h"
      #include "verilated.h"

      vluint64_t main_time = 0;

      double sc_time_stamp () {
          return main_time;
      }

      int main(int argc, char **argv, char **env) {
          Verilated::commandArgs(argc, argv);
          V$top_module* top = new V$top_module;
          top->clk = 0;
          while (!Verilated::gotFinish()) {
            top->eval();
            main_time++;
            top->clk = !top->clk;
          }
          top->final();
          delete top;
          exit(0);
      }
EOF
  $VERILATOR_ROOT/bin/verilator --cc -f $vf --exe $top_module.cpp
  cd obj_dir
  make -j -f V$top_module.mk V$top_module USER_CPPFLAGS="-DSC_CPLUSPLUS=199711L"
  cd -
  cp obj_dir/V$top_module $output -f
else
  touch $output
fi
