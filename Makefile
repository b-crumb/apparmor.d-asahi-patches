DESTDIR=
RULESDIR=/etc/apparmor.d

ABSTRACTIONS=$(shell find abstractions -type f -print)
LOCAL=$(shell find local -type f -printf "$(DESTDIR)$(RULESDIR)/local/%P\n")

# we just need the files in RULESDIR, the files data in local is irrelevant
SYMLINKS_DISABLE=$(shell find disable -type f -printf "$(DESTDIR)$(RULESDIR)/%P\n")
SYMLINKS_DISABLE_BOOTABLE=$(shell find succeeding-boot-disable -type f -printf "$(DESTDIR)$(RULESDIR)/%P\n")

all: ;

install:
	install -m0644 -t $(DESTDIR)$(RULESDIR)/local local/*
	install -m0644 -D $(ABSTRACTIONS) $(addprefix $(DESTDIR)$(RULESDIR)/,$(ABSTRACTIONS))

install-disabled: install
	# relative symlinks can be moved around
	ln -rst $(DESTDIR)$(RULESDIR)/disable $(SYMLINKS_DISABLE_BOOTABLE)

install-production: install
	# relative symlinks can be moved around
	ln -rst $(DESTDIR)$(RULESDIR)/disable $(SYMLINKS_DISABLE)

uninstall:
	rm -f $(LOCAL)
	rm -f $(addprefix $(DESTDIR)$(RULESDIR)/,$(ABSTRACTIONS))
	# Yes, should be careful with this one. -type d -empty is safe enough.
	find $(DESTDIR)$(RULESDIR)/abstractions -type d -empty -delete -printf "deleted %p"

uninstall-disabled: uninstall
	rm -f $(SYMLINKS_DISABLE_BOOTABLE)

uninstall-production: uninstall
	rm -f $(SYMLINKS_DISABLE)

debug:
	echo $(LOCAL)

.PHONY: all install install-disabled install-production uninstall uninstall-disabled uninstall-production debug
