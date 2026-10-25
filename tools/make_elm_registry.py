"""Write ~/.elm/0.19.1/packages/registry.dat from the packages already in the cache.

Elm 0.19.1 refuses to build without its package index (registry.dat). In sandboxes
where package.elm-lang.org is unreachable, we clone packages from GitHub into the
cache and generate the index here. Binary layout follows Elm's Deps.Registry:
  Registry = count:Int64, Map Name KnownVersions
  Name     = author:utf8<256, project:utf8<256
  Known    = newest:Version, previous:[Version]
"""
import os, struct, pathlib

root = pathlib.Path(os.environ.get("ELM_HOME", pathlib.Path.home() / ".elm")) / "0.19.1" / "packages"

def i64(n): return struct.pack(">q", n)
def short(s): b = s.encode(); return bytes([len(b)]) + b
def version(v):
    a, b, c = (int(x) for x in v.split("."))
    return bytes([a, b, c])

packages = {}
for author in sorted(p for p in root.iterdir() if p.is_dir()):
    for project in sorted(p for p in author.iterdir() if p.is_dir()):
        versions = sorted((v.name for v in project.iterdir() if v.is_dir()),
                          key=lambda v: tuple(int(x) for x in v.split(".")))
        if versions:
            packages[(author.name.encode(), project.name.encode())] = versions

out = bytearray(i64(sum(len(v) for v in packages.values())))
out += i64(len(packages))
for (author, project), versions in sorted(packages.items()):
    out += short(author.decode()) + short(project.decode())
    out += version(versions[-1])
    previous = list(reversed(versions[:-1]))
    out += i64(len(previous)) + b"".join(version(v) for v in previous)

(root / "registry.dat").write_bytes(bytes(out))
print(f"registry.dat: {len(packages)} packages")
