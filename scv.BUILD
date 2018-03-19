package(default_visibility = ["//visibility:public"])

cc_library(
  name = "scv",
  srcs = glob(["*/libscv.a"]),
  hdrs = glob(["include/**"]),
  includes = ["include"],
  deps = ["@systemc//:systemc"],
)

filegroup(
  name = "scv_filegroup",
  srcs = glob(["**"]),
)
