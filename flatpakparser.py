#!/usr/bin/env python3

import json
import os, sys
import uuid

if __name__=="__main__":
  if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0].split("/")[-1]} [Flatpak Manifest file]")
    exit()
  if not os.path.exists(sys.argv[1]):
    print("Error: Manifest file doesnt exists.")
    exit()
  if os.path.isdir(sys.argv[1]):
    print("Error: Wrong file.")
    exit()
  with open(sys.argv[1], "r") as f:
    try:
      manifest = json.load(f)
    except:
      print("Error: Wrong file.")
      exit()

  print(f"\nManifest Info\n==========================\n"
        f"App     | {manifest['app-id']}\n"
        f"Runtime | {manifest['runtime']}//{manifest["runtime-version"]}\n"
        f"SDK     | {manifest['sdk']}\n"
        f"CMD     | {manifest['command']}\n"
        f"Modules | \n - "
        f"{"\n - ".join([f"{i["name"]}\n  - {i["sources"][0]["url"]}" for i in manifest["modules"]])}\n"
        )

  global_script = []
  WORKDIR = ""
  workdir = f"./build-{str(uuid.uuid1())[:8]}" if not WORKDIR else WORKDIR
  print(f"Set workdir to {workdir}\n")

  global_script.append(f"if [ $(ls \"{workdir}\" | wc -l) -ne 0 ]; then exit; fi")
  global_script.append(f"mkdir -p {workdir}")
  global_script.append(f"ROOTDIR=$(realpath {workdir})")
  global_script.append("cd ${ROOTDIR}")

  for module in manifest["modules"]:
    script = []
    name = module["name"]
    build = module["buildsystem"]
    builddir = module.get("builddir", False)
    sources =  module["sources"]
    opts = module.get("config-opts", [])

    for src in sources:
      if src["type"] == "git":
        script.append(f"git clone {src["url"]} ./{name}.src")
        script.append(f"cd ./{name}.src")
        if src.get("tag"):
          # Need to fetch tags?
          script.append(f"git checkout {src["tag"]}")
        elif src.get("commit"):
          script.append(f"git checkout {src["commit"]}")
        elif src.get("branch"):
          # Switch to branch?
          script.append(f"git checkout {src["branch"]}")

      elif src["type"] == "file":
        script.append(f"cp -r {src["url"]} {workdir}/{name}.src")

    if build == "meson":
      script.append("meson setup build/")
      script.append("meson configure build/ " + " ".join(opts))
      script.append("cd build/; ninja")
      script.append("ninja install")

    elif build == "cmake-ninja":
      script.append("cmake .")
      script.append("cd build/; ninja; ninja install")

    global_script += script
    global_script.append("cd ${ROOTDIR}")
  
print("\n".join(global_script))