# Frequent Asked Questions

Last updated: `2024-12-23`

### Can I use Mi Home app with the speaker patch?

No, by using default patching, all Xiaomi software gets removed and replaced with lots of
different software to play audio managed from multiple sources,
such as AirPlay, MPD, UPNP, Squeezelite (LMS), or Snapcast.

You can manage the speaker via SSH, or the web-ui API (still work in progress),
and connect it to Home Assistant to use as a Voice Assistant.

### How can I connect the speaker to a wireless (Wi-Fi) network?

Press the Play button **5** times, then use [improv-wifi](https://www.improv-wifi.com)
with your smartphone to connect your speaker to a wireless network.

Alternatively, if you are in terminal / console mode, use `/bin/wifi_connect $SSID $PASSWORD`
to configure the wireless network.

### How can I pair the speaker via Bluetooth?

Press the Play button **3** times.
The speaker will be in Bluetooth pairing mode for about 45 seconds.

Alternatively, use `/bin/bluetooth_pair` command.

### How can I manage the speaker?

Use your phone or computer and connect to the IP of the speaker to port 80 (as a website).
For example: http://192.168.1.40

### How can I rename the Bluetooth speaker name?

Edit the file `/data/bt/bluez/bluetooth/main.conf`, update the `Name` section.
Then run `/etc/init.d/bluetoothd restart`.

### There are errors when using the voice assistant (listener)

You can modify additional config in `/data/listener` file.

Perform the following checks:
- Check the STT service exists in Home Assistant and is available (query the Home Assistant API for more details).
- Check the STT language provided exists (eg. `en`, `ca-ES`). Value will change depending on the different provider selected.
- You can replace the token with a [long-lived token](https://my.home-assistant.io/redirect/profile/) in your Profile > Security.
- Check logs in `/tmp/stt.*`.

If you still have issues, you may open an issue with details to help troubleshoot it.

### How can I change the root password?

We are using busybox tools, and `passwd` will write a temporal file in a location which is read-only.
Instead, create your hashed password and update the file in `/etc/shadow` with it.

```sh
openssl passwd -5 "your password"
```

> [!NOTE]
> It's recommended that you also copy an `ssh-key` to your speaker to ensure you will remain having access via SSH.

```sh
curl https://github.com/your-user.keys > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

