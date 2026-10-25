"""Fetch Elm packages (and their dependencies) from GitHub into the Elm cache.

For sandboxes that can reach github.com but not package.elm-lang.org.
Usage: python3 tools/fetch_elm_packages.py author/name [author/name ...]
Picks the newest release tag inside each dependency's allowed range, then run
tools/make_elm_registry.py so the compiler knows about them.
"""
import json, os, pathlib, re, shutil, subprocess, sys

cache = pathlib.Path(os.environ.get("ELM_HOME", pathlib.Path.home() / ".elm")) / "0.19.1" / "packages"

def tags(name):
    out = subprocess.run(["git", "ls-remote", "--tags", f"https://github.com/{name}"],
                         capture_output=True, text=True, check=True).stdout
    found = {line.split("refs/tags/")[1] for line in out.splitlines() if "refs/tags/" in line and "^{}" not in line}
    return sorted((t for t in found if re.fullmatch(r"\d+\.\d+\.\d+", t)),
                  key=lambda t: tuple(map(int, t.split("."))))

def in_range(version, constraint):
    low, _, _, _, high = constraint.split()
    v = tuple(map(int, version.split(".")))
    return tuple(map(int, low.split("."))) <= v < tuple(map(int, high.split(".")))

def fetch(name, constraint=None, seen=set()):
    if name in seen:
        return
    seen.add(name)
    existing = sorted((p.name for p in (cache / name).glob("*")), key=lambda t: tuple(map(int, t.split(".")))) if (cache / name).exists() else []
    candidates = [t for t in tags(name) if constraint is None or in_range(t, constraint)]
    if existing and (constraint is None or any(in_range(v, constraint) for v in existing)):
        version = existing[-1]
    else:
        version = candidates[-1]
        dest = cache / name / version
        subprocess.run(["git", "clone", "-q", "--depth", "1", "--branch", version, f"https://github.com/{name}", str(dest)], check=True)
        shutil.rmtree(dest / ".git", ignore_errors=True)
        print(f"fetched {name} {version}")
    deps = json.loads((cache / name / version / "elm.json").read_text())["dependencies"]
    for dep, dep_constraint in deps.items():
        fetch(dep, dep_constraint)

for package in sys.argv[1:]:
    fetch(package)
