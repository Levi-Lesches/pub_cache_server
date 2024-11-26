import json
import tarfile
import os

from flask import Flask, make_response
from pathlib import Path
from datetime import datetime

app = Flask(__name__)

# This is a custom Pub server. You can run `dart pub get` on this.
# 
# There are two reasons we might want this: 
# - The rover does not have internet access, in times when our own laptops might. If you want to 
#   test code on the rover and need to get a new package, you can point the rover to this server
#   and it will download from your computer instead
# - The same as above, but even your laptop may not have Internet access

pub_cache = r"D:\.tools\pub\hosted\pub.dev"
host = "192.168.1.10"
port = 8000

# Gets all security advisories for a package. We don't care about this.
@app.get("/api/packages/<package>/advisories")
def get_advisories(package): return {
  "advisories": [],
  "advisoriesUpdated": datetime.now().isoformat()
}

# Gets info for all versions of a package.
# 
# The approach here is simple: 
# - look for the cache file in your own device's pub.dev cache (or return 404)
# - change all the URLs to point to our own server
# - remove all the integrity checks so Pub doesn't complain
# - return the data mostly as-is
@app.get("/api/packages/<package>")
def get_versions(package):
  version_cache = Path(f"{pub_cache}\\.cache\\{package}-versions.json")
  if not version_cache.exists(): return "Not found", 404
  with open(version_cache.absolute()) as file: 
    version_data = json.load(file)
  for version in version_data["versions"]:
    version_number = version["version"]
    version["archive_url"] = f"http://{host}:{port}/api/archives/{package}-{version_number}.tar.gz"
    version["archive_sha256"] = None
  version_data["archive_url"] = f"http://{host}:{port}/api/archives/{package}-{version_number}.tar.gz"
  version_data["archive_sha256"] = None
  return version_data

# Gets the given package at the given version as a compressed tarball.
# 
# This function: 
# - finds the package and version in your own device's pub.dev cache (or returns 404)
# - checks if such a tarball already exists, and returns it if so
# - invokes [make_tarball] on the cached package and returns the result
@app.get("/api/archives/<package>-<version>.tar.gz")
def get_tarball(package, version):
  package_path = Path(f"{pub_cache}\\{package}-{version}")
  if not package_path.exists(): return "Not found", 404
  Path(f"{pub_cache}\\.tarballs").mkdir(exist_ok=True)
  output = Path(f"{pub_cache}\\.tarballs\\{package}-{version}.tar.gz")
  if not output.exists(): make_tarfile(source=package_path, dest=output)
  response = make_response(output.read_bytes())
  response.headers["Content-Type"] = "application/octet-stream"
  return response

# Makes a compressed tarball (.tar.gz) out of a directory
def make_tarfile(source, dest):
  with tarfile.open(dest.absolute(), "w:gz") as tar:
    for root, _, files in os.walk(source):
      for file in files: 
        file_path = os.path.join(root, file)
        arcname = os.path.relpath(file_path, source)
        tar.add(file_path, arcname=arcname)

app.run(host=host, port=port, debug=True)
