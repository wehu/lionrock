package(default_visibility = ["//visibility:public"])

cc_library(
  name = "uvm_systemc",
  srcs = glob(["*/libuvm-systemc.a"]),
  hdrs = glob(["include/**"]),
  includes = ["include"],
  deps = ["@systemc//:systemc"],
)

filegroup(
  name = "uvm_systemc_filegroup",
  srcs = glob(["**"]),
)
