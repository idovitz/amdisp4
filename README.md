# amdisp4 v10 dkms for kernel 7.0+

Sources for the AMD ISP4 (AMD image processing gen 4), to be built as a dkms module

https://lore.kernel.org/lkml/20260320084146.200988-1-Bin.Du@amd.com/

Used by ArchLinux [amdisp4-dkms](https://aur.archlinux.org/packages/amdisp4-dkms) AUR package
 
## How to update the patch dataset:

### Use [b4](https://b4.docs.kernel.org/en/latest/) tool to download the thread mbox from lklm:
```
$ uvx b4 am -o lklm/ 20260320084146.200988-1-Bin.Du@amd.com
Looking up https://lore.kernel.org/all/20260320084146.200988-1-Bin.Du@amd.com/
Grabbing thread from lore.kernel.org/all/20260320084146.200988-1-Bin.Du@amd.com/t.mbox.gz
Analyzing 13 messages in the thread
Looking for additional code-review trailers on lore.kernel.org
Analyzing 163 code-review messages
Checking attestation on all messages, may take a moment...
---
  ✓ [PATCH v10 1/7] media: platform: amd: Introduce amd isp4 capture driver
  ✓ [PATCH v10 2/7] media: platform: amd: low level support for isp4 firmware
    + Signed-off-by: Sultan Alsawaf <sultan@kerneltoast.com> (✗ DKIM/kerneltoast.com)
  ✓ [PATCH v10 3/7] media: platform: amd: Add isp4 fw and hw interface
  ✓ [PATCH v10 4/7] media: platform: amd: isp4 subdev and firmware loading handling added
  ✓ [PATCH v10 5/7] media: platform: amd: isp4 video node and buffers handling added
  ✓ [PATCH v10 6/7] media: platform: amd: isp4 debug fs logging and more descriptive errors
  ✓ [PATCH v10 7/7] Documentation: add documentation of AMD isp 4 driver
    + Signed-off-by: Sultan Alsawaf <sultan@kerneltoast.com> (✗ DKIM/kerneltoast.com)
  ---
  ✓ Signed: DKIM/amd.com
---
Total patches: 7
---
Cover: lklm/v10_20260320_bin_du_add_amd_isp4_driver.cover
 Link: https://patch.msgid.link/20260320084146.200988-1-Bin.Du@amd.com
       git am lklm/v10_20260320_bin_du_add_amd_isp4_driver.mbx
```

### Generate patch series with [mbox_split.py](https://gist.github.com/bonzini/d5bc1946475487167c529f9699e39512/)
```
$ cd patches && rm -f *.patch && python ../mbox_split.py ../lklm/v10_20260320_bin_du_add_amd_isp4_driver.mbx
0001-media-platform-amd-Introduce-amd-isp4-capture-driver.patch
0002-media-platform-amd-low-level-support-for-isp4-firmware.patch
0003-media-platform-amd-Add-isp4-fw-and-hw-interface.patch
0004-media-platform-amd-isp4-subdev-and-firmware-loading-handling-added.patch
0005-media-platform-amd-isp4-video-node-and-buffers-handling-added.patch
0006-media-platform-amd-isp4-debug-fs-logging-and-more-descriptive-errors.patch
0007-Documentation-add-documentation-of-AMD-isp-4-driver.patch
```

### Strip useless files for dkms module

With `filterdiff` from `patchutils`

```
$ filterdiff  -p1 --clean -x "drivers/media/platform/Makefile" -x MAINTAINERS -x "drivers/media/platform/Kconfig" --in-place 000*.patch
```

### Commit the changes.

Then you can update the amdisp4-dkms PKGBUILD
