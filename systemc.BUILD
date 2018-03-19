package(default_visibility = ["//visibility:public"])

cc_library(
  name = "systemc",
  srcs = glob(["*/libsystemc.a"]),
  hdrs = glob(["include/**"]),
  includes = ["include"],
  defines = ["SC_CPLUSPLUS=199711L"],
  linkopts = ["-lpthread"]
)
