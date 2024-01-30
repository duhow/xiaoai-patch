# Frequent Asked Questions

Last updated: `2024-01-30`

### How can I connect the speaker to a wireless (Wi-Fi) network?

Press the Play button **5** times, then use [improv-wifi](https://www.improv-wifi.com)
with your smartphone to connect your speaker to a wireless network.

Alternatively, if you are in terminal / console mode, use `/bin/wifi_connect $SSID $PASSWORD`
to configure the wireless network.

### How can I pair the speaker via Bluetooth?

Press the Play button **3** times.
The speaker will be in Bluetooth pairing mode for about 45 seconds.

Alternatively, use `/bin/bluetooth_pair` command.

### How can I rename the Bluetooth speaker name?

Edit the file `/data/bt/bluez/bluetooth/main.conf`, update the `Name` section.
Then run `/etc/init.d/bluetoothd restart`.
