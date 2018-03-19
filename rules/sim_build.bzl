# simulation compiling

load("//rules:const.bzl", "default_vendor")
load("//rules:block.bzl", "block_aspect")
load("//rules:sim_assembly.bzl", "sim_assembly", "sim_all_inputs", "sim_top_module_name")

def _sim_build_rule_impl(ctx):

  vendor = ctx.attr.vendor
  vf = ctx.outputs.vf
  ws = vf.dirname
  out = ctx.outputs.out
  top_module = sim_top_module_name(ctx)

  content = sim_assembly(ctx)

  ctx.actions.write(
    output=vf,
    content="\n".join(content))

  inputs = sim_all_inputs(ctx)

  simctl = ctx.executable._simctl
  ctx.actions.run(executable = simctl,
    arguments = [vendor, ws, top_module, out.basename, vf.basename],
    inputs = inputs + [vf, simctl],
    outputs = [out],
    use_default_shell_env=True)

sim_build = rule(
  implementation=_sim_build_rule_impl,
  attrs={
    "deps": attr.label_list(aspects=[block_aspect]),
    "vendor": attr.string(default=default_vendor),
    "top_module_file": attr.label(allow_single_file=True),
    "_simctl": attr.label(default=Label("//rules:simctl"),
                          allow_files=True, executable=True, cfg="host")
  },
  outputs = {"vf": "sim/%{name}/%{name}.files",
             "out": "sim/%{name}/%{name}.exe"},
)

