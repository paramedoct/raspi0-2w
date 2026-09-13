## RASPI0-2W
- Bring raspbian to microsd card using official imager
- Find root partition from `bootfs/cmdline.txt`
- Paste into `provision/cmdline.txt`
- Replace passwd placeholder in `provision/user-data`
- Overwrite microsd card with `provision/*`
```
# network
sudo nmcli radio wifi on
sudo nmcli device wifi list
sudo nmcli device wifi connect <ssid> --ask

# pinmap
pinout
```
