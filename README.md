Debian installer CD for PC Engines APU board with mSATA drive
=============================================================

Introduction
------------

This is a set of configuration files for building a Debian installation
CD optimized for the APU platform of PC Engines:
http://www.pcengines.ch/apu.htm

This installation is only intended for an mSATA drive on the APU
board. If you plan to boot from SD card, use Voyage Linux instead:
http://linux.voyage.hk/

The configuration files build an amd64 installer for the APU platform
(APU versions 1, 2, and 3 have been tested).

The build machine MUST be of the same Debian release as the image that
you are building: a Buster host can produce a Buster ISO, and a Stretch
host can produce a Stretch ISO.

Before using these scripts, have a look at the files in profiles/, and
you may want to change some options. The "wget_debian_mirror" parameter
should point to a working FTP mirror, so you may want to select a mirror
near you.


"apu64" profile
---------------

This profile is designed to automate as much as possible.

The default hostname is set to "gw", unless DHCP delivers a different
name. Default root password is "pcengines", and it is defined in
"profiles/apu64.preseed".

If you want to change the hostname edit "profiles/apu64.preseed".

The disk layout does not allocate a swap partition (the APU board has 2
or 4GB RAM). If you need swap, you can add a swapfile in root
partition. The system is optimized for minimal swap usage:
vm.swappiness=1 in /etc/sysctl.d/pcengines_apu.conf

The profile adds an hourly cronjob
(/etc/cron.hourly/pcengines_apu_fstrim) which performs fstrim command on
root and boot partitions once a day.


Notes
-----

The kernel boots with "elevator=deadline", which optimizes the I/O
performance for SSD drives.

See also SSD optimization tips:
https://wiki.freeswitch.org/wiki/SSD_Tuning_for_Linux
https://wiki.debian.org/SSDOptimization

If you need a live or rescue CD, you can get a Live CD from Voyage
Linux. It works fine, the only minor issue is that it switches the
serial console to 9600 baud: http://linux.voyage.hk/

The SSH daemon now has `PermitRootLogin without-password` by default,
which disallows the root to login with a password. You either need to
install your public SSH key in root's autorized_keys, or change the SSH
daemon configuration.
This setting is overridden during the installation, please secure it later!


Building the image
------------------

The build machine needs to be Debian Buster. Other Debian versions or
Ubuntu are not fully tested and there are some issues, not yet fully
investigated.


Build the CD image on the build machine:

1. install prerequisites

```
apt-get update
apt-get install -y simple-cdd git-core
```

2. get our latest files

```
mkdir /opt/pcengines
cd /opt/pcengines
git clone https://github.com/antonyx/pcengines-apu-debian-cd.git .
```

3. build the installation CD image. If you need to build another ISO
image of a different architecture inside the same path, delete the
contents of "tmp/" subdirectory.

Run the following command as anormal user.
If you run it as root, use "--force-root" option:

./build.sh apu64


Build the CD image on the build machine using Docker.

Run the following command to build the apu64 profile:

./docker-build.sh apu64


In case of a failure, delete the contents of tmp/ subfolder.
Sometimes problems with accessing the mirror leave garbage in tmp/
and this breaks the execution of build-simple-cdd


Binary releases
---------------

64-bit installer ISO images are available at GitHub in Releases section:

https://github.com/antonyx/pcengines-apu-debian-cd/releases


Installation
------------

WARNING: this is a fully automated installation. Once you boot from the
USB stick, it will only give you 5 seconds in the initial menu, then in
a couple of minutes it will ask for the hostname, and the rest will be
done automatically, and a new Debian system will be installed on mSATA
SSD drive.

!!! ALL EXISTING DATA ON THE DRIVE WILL BE LOST !!!

Both the build machine and the APU board need the Internet connection
during the installation. The installer assumes that eth0 (marked as
LAN1 on the APU board) is connected to a network with DHCP service and
Internet access.

The installation ISO image is about 350MB in size.

1. Download the binary release or build the installation ISO image file

2. Insert the USB stick into the build machine

3. Check where your USB stick is using:

fdisk -l

4. Copy the installer CD image and check the correct target device

dd if=images/debian-10-amd64-CD-1.iso of=/dev/sdc bs=16M

5. Insert the USB stick into APU board and connect a serial terminal at
115200 baud rate.
The terminal emulator should be vt220 or xterm (vt100 does not have F10 and F12).

APU model 1 uses F12, and APU model 2 uses F10 in the boot prompt.
When the prompt appears, press F12 or F10, correspondingly,
and select your USB stick as boot source.

The installation starts automatically and halt when the installation finishes.

Note: It's mandatory for fully automated installation to have a working internet connection
with DHCP enabled on one of the available ethernet ports.


Author
------
Anto Nix

Forked from a work of Stanislav Sinyagin <ssinyagin@k-open.com>
