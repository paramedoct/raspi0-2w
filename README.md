## RASPI0-2W
- Bring raspbian to microsd card using official imager
- Find root partition from `bootfs/cmdline.txt`
- Paste into `microsd/cmdline.txt`
- Replace passwd placeholder in `microsd/user-data`
- Overwrite microsd card with `microsd/*`
```
# network
sudo nmcli radio wifi on
sudo nmcli device wifi list
sudo nmcli device wifi connect <ssid> --ask

# pinmap
pinout
```
<br></br>
