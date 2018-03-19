# this is a simple feature system
# it will generate macro definitions for c/c++ and verilog
load("//rules:block.bzl", "FileCollector")

Features = provider("defines")

def check_feature_key(key):
  ks = key.split(".")
  if len(ks) != 3:
    fail("feature key should like xxx.yyy.zzz, but got {}".format(key))

def get_transitive_features(defines, deps):
  defs = []
  for k in defines:
    check_feature_key(k)
    defs.append("{} {}".format(k.replace(".", "_").upper(), defines[k]))
  return depset(
        defs,
        transitive = [dep[Features].defines for dep in deps])

def _feature_impl(ctx):

  if ctx.attr.name.rfind("_features") != len(ctx.attr.name)-9:
    fail("features name expects suffix _features, but got {}".format(ctx.attr.name))

  cc_h = ctx.outputs.cc
  vh = ctx.outputs.verilog

  defines = get_transitive_features(ctx.attr.defines, ctx.attr.deps)

  upper_name = ctx.attr.name.upper()

  content_cc = ["#ifndef __{}_H__".format(upper_name),
                "#define __{}_H__ 1".format(upper_name),]
  for k in defines:
    content_cc.append("#define {}".format(k))
  content_cc += ["#endif",""] # trailing newline

  ctx.actions.write(
    output=cc_h,
    content="\n".join(content_cc))  

  content_vh = ["`ifndef __{}_VH__".format(upper_name),
                "`define __{}_VH__ 1".format(upper_name),]
  for k in defines:
    content_vh.append("`define {}".format(k))
  content_vh += ["`endif",""]

  ctx.actions.write(
    output=vh,
    content="\n".join(content_vh))

  return [Features(defines=defines),
          FileCollector(files=depset([cc_h, vh]),
			incs=depset([]),
                        defines=depset([]),
                        features=depset([vh]))]

features = rule(
    implementation = _feature_impl,
    attrs = {
        "defines": attr.string_dict(),
        "deps": attr.label_list(),
    },
    output_to_genfiles = True,
    outputs = {"cc": "features/%{name}.h",
               "verilog": "features/%{name}.vh",}
)

