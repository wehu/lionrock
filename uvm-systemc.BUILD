package(default_visibility = ["//visibility:public"])

cc_library(
  name = "uvm_systemc",
  srcs = glob(["*/libuvm-systemc.a"]),
  hdrs = glob(["include/**"]),
  includes = ["include"],
  deps = ["@systemc//:systemc"],
)
