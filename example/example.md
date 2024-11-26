
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
