load("//rules:block.bzl", "block_aspect", "FileCollector")
load("//rules:sim_assembly.bzl", "sim_assembly", "sim_all_inputs", "sim_top_module_name")

VerilatorFiles = provider("files")

def _verilator_library_rule_impl(ctx):

  vf = ctx.outputs.vf
  lib = ctx.outputs.lib
  hdr = ctx.outputs.hdr
  dpi_hdr = ctx.outputs.dpi_hdr
  varilated = ctx.outputs.verilated
  ws = lib.dirname
  top_module = sim_top_module_name(ctx)
  mode = ctx.attr.mode

  content = sim_assembly(ctx)

  ctx.actions.write(
    output=vf,
    content="\n".join(content))

  inputs = sim_all_inputs(ctx)

  verilator = ctx.executable._verilator
  verilator_files = ctx.attr._verilator_filegroup.files
  systemc_files = ctx.attr._systemc_filegroup.files
  ctx.actions.run(executable = verilator,
    arguments = [ws, top_module, mode, lib.basename, hdr.basename, dpi_hdr.basename, vf.basename],
    inputs = inputs + [vf, verilator] + verilator_files + systemc_files,
    outputs = [lib, hdr, dpi_hdr, varilated],
    use_default_shell_env=True)

verilator_library = rule(
  implementation=_verilator_library_rule_impl,
  attrs={
    "deps": attr.label_list(aspects=[block_aspect]),
    "mode": attr.string(default="sc"),
    "vendor": attr.string(default="verilator"),
    "top_module_file": attr.label(allow_single_file=True),
    "_verilator": attr.label(default=Label("//rules:verilator"),
                          allow_files=True, executable=True, cfg="host"),
    "_verilator_filegroup": attr.label(default="@verilator//:verilator_filegroup"),
    "_systemc_filegroup": attr.label(default="@systemc//:systemc_filegroup"),
  },
  output_to_genfiles = True,
  outputs = {"vf": "%{name}.files",
             "lib": "%{name}.a",
             "hdr": "%{name}.h",
             "dpi_hdr": "%{name}_dpi.h",
             "verilated": "verilated.o"},
)

