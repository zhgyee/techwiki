# Introduction #

Add your content here.


# change default kernel #

Open grub2 default config

sudo vim /etc/default/grub

Comment out the two lines and set a proper timeout

# GRUB\_HIDDEN\_TIMEOUT=0
# GRUB\_HIDDEN\_TIMEOUT\_QUIET=true
GRUB\_TIMEOUT=10
Update grub

sudo update-grub2

Reboot and select the older kernel