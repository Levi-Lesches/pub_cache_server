# pub_cache_server

A Pub server that serves packages from your device's local Pub cache.

This can be a useful tool for when a remote device needs to run `dart pub get` but cannot access pub.dev or the package(s) you need are not on pub.dev. Instead, this tool can be used to redirect all pub commands to a host device on your network that does have the packages you need.

For example – you need to install packages on a Rasberry Pi in the middle of the desert with no internet, but you have a laptop and _prep time_:
- First, install packages on your own laptop using `dart pub get` as normal
- Once you're offline, run this tool to turn your laptop into a Pub server
- Now the Pi can install any packages it needs – as long as your laptop already has them

On your laptop (the host device):
```bash
# Download this package
dart pub global activate pub_cache_server
# Get the packages for yourself first
dart pub get
# Start the server
pub_cache_server -a 192.168.1.10
```

Make sure to use your own IP address for the last line. By default, the server runs on port 8000, but you can change that with the `-p` option.

On the Raspberry Pi (the remote device):
```bash
# On the remote device, change the Pub URL to your laptop's IP
export PUB_HOSTED_URL=http://192.168.1.10:8000
# Run dart pub commands as normal
dart pub get
```

### Important notes

- Make sure that your `PUB_HOSTED_URL` is `http://`, _not_ `https://`
- Make sure that your devices can at least ping each other
- If you run into issues on the remote device, try using `dart pub get --verbose` to see where the errors happen
- The server will serve directly from your own Pub cache and works entirely offline. This means it cannot possibly serve a package you yourself don't have. To make sure you are prepared for an offline scenario, run `dart pub get` in all the projects you will need before going offline. This will make sure you have all the files needed in order to provide them to the offline device.

### Limitations

These are not fundamental limitations, just features I don't need. If these are a blocked for you, consider opening an issue or Pull Request on GitHub.
- This package does not yet support publishing to the local server.

- This package only pulls from your hosted cache, so it cannot serve from other sources, such as path, or Git.

  - For local packages, consider: 

    - using SCP to copy them to the remote device and use a `path` dependency
    - if the package is only relevant to one project, embed it in the project using a Pub Workspace

  - For local packages under active development, consider using `git push` over SSH: 

    - use SCP to copy them to the remote device and use a `path` dependency

    - If you need to make changes to the repository, push the package from the host to the remote:

      ```bash
      # On the host device, using the remote device's IP
      git remote add pi user@192.168.1.20:~/pkg  # one-time
      git push pi main  # when you want to update the remote device
      ```

    - it is not recommended to use a `git` dependency with the host IP in the URL, since that will commit your host's IP in your source control

- This package assumes hosted packages were downloaded from Pub.dev, as this affects which folder they're in

  - You may specify other Pub servers, eg, `pub_cache_server -d onepub.dev`
  - You may only specify one Pub server at a time

