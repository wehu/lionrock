# simulation assembly

load("//rules:block.bzl", "FileCollector")

def sim_top_module_name(ctx):
  top_module = ctx.attr.name
  if ctx.attr.top_module_file:
    f = ctx.file.top_module_file
    fn = f.basename
    ext = len(f.extension)
    top_module = fn[:(-1-ext)]
  return top_module

def sim_all_inputs(ctx):
  return depset(
           direct=[],
           transitive=[dep[FileCollector].files for dep in ctx.attr.deps] \
                        + [dep.files for dep in ctx.attr.deps],
           order="topological")

sep = "/"

def get_relative_depth(ws):
  vf_depth = ws.split(sep)
  rel_depth = []
  for d in vf_depth:
    rel_depth.append("..")
  depth = sep.join(rel_depth)
  return depth

def sim_assembly(ctx):

  vf = ctx.outputs.vf
  ws = vf.dirname

  vendor = ""
  if hasattr(ctx.attr, "vendor"):
    vendor = ctx.attr.vendor

  # relative depth
  depth = get_relative_depth(ws)

  content = []

  # defines
  for dep in ctx.attr.deps:
    defines = [define for define in reversed(dep[FileCollector].defines.to_list())]
    for define in defines:
      content.append(define)

  # includes
  for dep in ctx.attr.deps:
    incs = [inc.path for inc in reversed(dep[FileCollector].incs.to_list())] \
           + [feature.dirname for feature in reversed(dep[FileCollector].features.to_list())]
    for inc in incs:
      content.append("+incdir+{}/{}".format(depth, inc))

  # system verilog
  for dep in ctx.attr.deps:
    files = [f.path for f in reversed(dep[FileCollector].files.to_list())
             if f.extension in ["sv"]]
    for f in files:
       content.append("{}{}{}".format(depth, sep, f))

  # verilog files
  top_module_file = ""
  has_top_module_file = hasattr(ctx.file, "top_module_file") and ctx.file.top_module_file
  if has_top_module_file:
    top_module_file = ctx.file.top_module_file.path
  for dep in ctx.attr.deps:
    files = [f.path for f in dep[FileCollector].files.to_list()
             if f.extension in ["v"]]
    for f in files:
       if top_module_file == "":
         top_module_file = f
       if top_module_file != f:
         content.append("-v {}{}{}".format(depth, sep, f))

  content.append("{}{}{}".format(depth, sep, top_module_file))

  # library
  for dep in ctx.attr.deps:
    files = [f.path for f in reversed(dep[FileCollector].files.to_list())
             if f.extension in ["a", "so"]]
    for f in files:
       d = depth
       if vendor == "verilator":
         d = "../{}".format(depth)
       content.append("{}{}{}".format(d, sep, f))

  content += [""] # trailing newline

  return content

