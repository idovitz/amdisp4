# amdisp4 — AMD ISP4 Webcam Fix for CachyOS

Out-of-tree DKMS module that fixes the AMD ISP4 (Image Signal Processor v4.1.1) webcam on CachyOS Linux. Tested on the HP ZBook Ultra G1a with AMD Ryzen AI MAX+ PRO 395 (Strix Halo).

Forked from [idovitz/amdisp4](https://github.com/idovitz/amdisp4), which provides the original patches from the [upstream ISP4 patchset](https://lore.kernel.org/lkml/20251128091929.165272-1-Bin.Du@amd.com/).

## What This Fixes

The in-tree `amd_isp4_capture` module shipped with CachyOS 6.19 is broken:

1. **Camera doesn't stream** — attempts to capture from `/dev/video0` fail
2. **Suspend hangs the system** — if the ISP module has been loaded, closing the lid (s2idle) causes the machine to freeze

This module replaces the in-tree version and fixes both issues.

## What We Changed

The source files are from the in-tree ISP4 driver at `drivers/media/platform/amd/isp4/`, adapted for out-of-tree building:

- **API replacement** — internal `amdgpu_bo_*` functions replaced with exported `isp_kernel_buffer_alloc/free` and `isp_user_buffer_alloc/free` from `<drm/amd/isp.h>`
- **`IRQF_NO_AUTOEN`** — IRQs registered with auto-enable disabled, preventing an interrupt storm during probe
- **PM suspend/resume ops** — `isp4_capture_suspend()` tears down ISP firmware and hardware state before sleep via `isp4sd_pwroff_and_deinit()`, preventing the SMU hang on resume
- **Removed files not needed out-of-tree** — `isp4_hw.c/h` and `isp4_phy.c/h` are handled by the kernel's ISP IP block layer

The kernel's DRM/AMDGPU ISP layer already handles firmware loading, MIPI PHY configuration, sensor enumeration, and power domain management. This module only needs to talk to the firmware via ring buffers and expose `/dev/video0`.

## Quick Install (Pre-built Module)

A pre-built `amd_capture.ko.zst` is included for **CachyOS 6.19.5-3-cachyos**. If you're on that exact kernel version:

```bash
sudo cp amd_capture.ko.zst /lib/modules/$(uname -r)/updates/dkms/
sudo depmod
sudo reboot
```

The module installs to `/updates/dkms/` which automatically overrides the broken in-tree version.

## Building From Source

Requires kernel headers and clang (CachyOS kernels are built with clang):

```bash
sudo pacman -S --needed linux-cachyos-headers base-devel clang llvm

git clone https://github.com/kinncj/amdisp4.git
cd amdisp4
make -C /lib/modules/$(uname -r)/build M=$(pwd) CC=clang LLVM=1 modules
```

Then install:

```bash
zstd amd_capture.ko -o amd_capture.ko.zst
sudo cp amd_capture.ko.zst /lib/modules/$(uname -r)/updates/dkms/
sudo depmod
sudo reboot
```

## Verification

```bash
# Module loaded
lsmod | grep amd

# No ISP errors
dmesg | grep -i isp

# Video device exists
v4l2-ctl --list-devices

# Camera works
mpv av://v4l2:/dev/video0

# Suspend/resume works
systemctl suspend
```

## Troubleshooting

**Build fails with gcc errors**: CachyOS kernels require `CC=clang LLVM=1`. Do not use gcc.

**Module won't load**: Check for a blacklist at `/etc/modprobe.d/blacklist-amd-capture.conf`. Remove or comment out any `blacklist amd_capture` or `install amd_capture /bin/false` lines, then `sudo mkinitcpio -P` and reboot.

**System hangs at boot**: Boot with `nomodeset`, remove the module, reinstall the kernel:
```bash
sudo rm -f /lib/modules/$(uname -r)/updates/dkms/amd_capture.ko.zst
sudo depmod
sudo pacman -S linux-cachyos linux-cachyos-headers
```

**Pre-built module doesn't load**: The `.ko.zst` is built for a specific kernel version. If yours differs, build from source.

## Kernel Updates

The module must be rebuilt for each kernel update. Either rebuild manually or set up DKMS using the included `dkms.conf` and `Makefile`.

## License

GPL-2.0 — same as the upstream Linux kernel ISP4 driver.
