.SUFFIXES: .dtb .dts

ifeq ($(HOSTDIR),)
$(error "You have to set $$HOSTDIR to point to your Buildroot host dir, in order to build!")
endif

ifeq ($(LINUX_DIR),)
$(error "You have to set $$LINUX_DIR to point to your Linux dir, in order to build!")
endif

ifeq ($(DESTDIR),)
DESTDIR=dtb
endif

DTC=$(HOSTDIR)/usr/bin/dtc
CPP=$(HOSTDIR)/usr/bin/arm-linux-gcc

TARGETS = \
	nonlinear-labs-2A.dtb \
	nonlinear-labs-2C.dtb \
	nonlinear-labs-2D.dtb

SRCARCH = arm
DOT_TARGET = $(dir $@).$(notdir $@)
COMMA = ,
DTC_TMP = $(subst $(COMMA),_,$(DOT_TARGET).dts.tmp)
DEPFILE = $(subst $(COMMA),_,$(DOT_TARGET).d)
DTC_FLAGS := -p 1024

dtc_cpp_flags  = -E -Wp,-MD,$@.pre.tmp -nostdinc			\
		 -I$(LINUX_DIR)/include					\
                 -I$(LINUX_DIR)/arch/$(SRCARCH)/boot/dts		\
                 -I$(LINUX_DIR)/arch/$(SRCARCH)/boot/dts/include	\
                 -I$(LINUX_DIR)/drivers/of/testcase-data		\
                 -undef -D__DTS__

cmd_dtc = @echo -e "$< -> $(DESTDIR)/$@"; \
	$(CPP) $(dtc_cpp_flags) -x assembler-with-cpp $< |		\
        $(DTC) -i $(LINUX_DIR)/arch/$(SRCARCH)/boot/dts -O dtb -o $(DESTDIR)/$@ -b 0 && \
	rm $@.pre.tmp

all: create_dirs $(TARGETS)

create_dirs:
	mkdir -p ./$(DESTDIR)

%.dtb: %.dts
	$(cmd_dtc)

clean:
	@rm -Rf ./$(DESTDIR)
	@rm -f *.tmp
	@rm -f dts.cramfs

.PHONY: all clean
