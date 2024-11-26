# pub_cache_server

A Pub server that serves packages from your Pub cache.

### Usage

To install,

```bash
dart pub global activate pub_cache_server
```

Then, run at any time using
```bash
pub_cache_server
```
or
```bash
dart pub global run pub_cache_server
```

This will run the server on `localhost:8000` by default (pass `-h` for more options). Now, tell Pub to use this server instead of Pub.dev:

```bash
# On Unix:
export PUB_HOSTED_URL=http://localhost:8000
# On Windows:
set PUB_HOSTED_URL=http://localhost:8000
```

Running any `dart pub` command will fetch from the cache server instead of Pub.dev. Note that these examples show how to run the server on localhost. You can also run the server across devices, like this:

```bash
pub_cache_server -a 192.168.1.10 -p 8005
export PUB_HOSTED_URL=http://192.168.1.10:8005
```

### Important notes

- Make sure that your `PUB_HOSTED_URL` is `http://`. _not_ `https://`
- If running across devices, make sure that your devices can at least ping each other
- The server will serve directly from your own Pub cache and works entirely offline. This means it cannot possibly serve a package you yourself don't have. To make sure you are prepared for an offline scenario, run `dart pub get` in all the projects you will need before going offline. This will make sure you have all the files needed in order to provide them to the offline device.

### Example

Say your device is `192.168.1.10` and you need to serve packages to a Raspberry Pi device on `192.168.1.20`. In this scenario, your device has Internet but the Pi does not. Here's how you'd work with that:

```bash
# Download this package
> dart pub global activate pub_cache_server
# Get the packages for yourself first
> cd dart_project
> dart pub get
# Start the server
> pub_cache_server -a 192.168.1.10
```
```bash
# Connect to the Raspberry Pi
> ssh pi@192.168.1.20
> # Enter password for user pi
# In the Raspberry Pi, change the Pub URL
$ export PUB_HOSTED_URL=http://192.168.1.10:8000
# Run dart pub commands as normal
$ cd dart_project
$ dart pub get  # will pull from
```

### Limitations
These are not fundamental limitations, just features I don't need. If you have a use-case, [open an issue](https://github.com/Levi-Lesches/pub_cache_server/issues/new/choose) for them.
- This package does not yet support publishing to the local server.
- This package only pulls from your hosted cache, so it cannot serve from other sources, such as path, or Git.
  - You may specify other Pub servers by, eg `-d pub.dev`
  - You may only specify one Pub server at a time
  - If you have the files locally, consider using `scp` or `git` to push the files to the remote device and use a `path: ` dependency override to get them.

