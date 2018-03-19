def _block_impl(ctx):
    return

block = rule(
    implementation=_block_impl,
    attrs={
        "deps": attr.label_list(allow_files=True),
        "srcs": attr.label_list(allow_files=True),
        "includes": attr.label_list(allow_files=True),
        "defines": attr.string_dict(),
})

FileCollector = provider(
  fields = {"files" : "collected files",
            "incs"  : "includes dir",
            "defines" : "defines",
            "features": "feature files"}
)

def _block_aspect_impl(target, ctx):

  if ctx.rule.kind == "features":
    return []

  # collect source files
  files=depset([])
  if hasattr(ctx.rule.files, 'srcs'):
    direct = [f for f in ctx.rule.files.srcs
               if f.extension in ["vh", "v", "a", "so", "sv", "svh", "tab"]]
    if hasattr(ctx.rule.attr, 'deps'):
      files = depset(
        direct=direct,
        transitive=[dep[FileCollector].files for dep in ctx.rule.attr.deps],
        order="topological")
    else:
      files = depset(
        direct=direct,
        transitive=[])

  # collect incdirs
  incs = depset([])
  if hasattr(ctx.rule.files, 'includes'):
    direct = [inc for inc in ctx.rule.files.includes]
    if hasattr(ctx.rule.attr, 'deps'):
      incs = depset(
        direct=direct,
        transitive=[dep[FileCollector].incs for dep in ctx.rule.attr.deps],
        order="topological")
    else:
      incs = depset(
        direct=direct,
        transitive=[])

  # collect definitions
  defines = depset([])
  if hasattr(ctx.rule.attr, 'defines') and type(ctx.rule.attr.defines) == "dict":
    direct = ["+define+{}={}".format(k.replace(".", "_").upper(), ctx.rule.attr.defines[k])
               for k in ctx.rule.attr.defines]
    if hasattr(ctx.rule.attr, 'deps'):
      defines = depset(
        direct=direct,
        transitive=[dep[FileCollector].defines for dep in ctx.rule.attr.deps],
        order="topological")
    else:
      defines = depset(
        direct=direct,
        transitive=[])

  # collect features
  features = depset([])
  if hasattr(ctx.rule.attr, 'deps'):
    features = depset(
      direct=[],
      transitive=[dep[FileCollector].features for dep in ctx.rule.attr.deps],
      order="topological")

  return [FileCollector(files=files, incs=incs, defines=defines, features=features)]

block_aspect = aspect(
  implementation=_block_aspect_impl,
  attr_aspects=["deps"],
  attrs={
  }
)

