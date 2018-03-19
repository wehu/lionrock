# run simulation

load("//rules:const.bzl", "default_vendor")

def _run_test_impl(ctx):

  vendor = ctx.attr.vendor
  cfg = ctx.attr.config
  name = ctx.attr.name
  args = ctx.attr.test_args

  files = [f.short_path for f in cfg.files.to_list()
           if f.extension == "exe" or f.extension == ""]

  simulator = ""
  if vendor == "verilator":
    simulator = ""
  elif vendor == "vcs":
    simulator = ""

  script = """
  {} {}
""".format(simulator, " ".join(files + [name] + args))

  # Write the file, it is executed by 'bazel test'.
  ctx.actions.write(
      output=ctx.outputs.executable,
      content=script)

  # To ensure the files needed by the script are available, we put them in
  # the runfiles.
  runfiles = ctx.runfiles(files=cfg.files.to_list()+ctx.attr.data)
  return [DefaultInfo(runfiles=runfiles)]

run_test = rule(
  implementation=_run_test_impl,
  attrs={
    "config": attr.label(mandatory=True),
    "vendor": attr.string(default=default_vendor),
    "test_args": attr.string_list(),
    "data": attr.label_list(allow_files=True),
  },
  test=True,
)

