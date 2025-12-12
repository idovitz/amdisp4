KERNEL_DIR ?= /lib/modules/$(KERNELRELEASE)/build
PWD := $(shell pwd)

obj-m += amd_capture.o
amd_capture-objs := isp4.o \
		    isp4_debug.o \
		    isp4_interface.o \
		    isp4_subdev.o \
		    isp4_video.o

default:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
