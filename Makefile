DESTDIR=
RULESDIR=/etc/apparmor.d

TUNABLES=$(shell find tunables -type f -print)
ABSTRACTIONS=$(shell find abstractions -type f -print)

TUNABLES_INSTALL=$(foreach tunable,$(TUNABLES),$(tunable) $(DESTDIR)$(RULESDIR)/$(tunable))
ABSTRACTIONS_INSTALL=$(foreach abstraction,$(ABSTRACTIONS),$(abstraction) $(DESTDIR)$(RULESDIR)/$(abstraction))

# we just need the files in RULESDIR, the files data in local is irrelevant
LOCAL=$(shell find local -type f -printf "$(DESTDIR)$(RULESDIR)/local/%P\n")
SYMLINKS_DISABLE=$(shell find disable -type f -printf "%P\n")
SYMLINKS_DISABLE_BOOTABLE=$(shell find succeeding-boot-disable -type f -printf "%P\n")

all: ;

install:
	install -m0644 -t $(DESTDIR)$(RULESDIR)/local local/*
	echo $(ABSTRACTIONS_INSTALL) | xargs -n2 install -m0644 -TD 
	echo $(TUNABLES_INSTALL) | xargs -n2 install -m0644 -TD 

install-disabled: install
	# relative symlinks can be moved around
	ln -frst $(DESTDIR)$(RULESDIR)/disable $(addprefix $(DESTDIR)$(RULESDIR)/,$(SYMLINKS_DISABLE_BOOTABLE))

install-production: install
	# relative symlinks can be moved around
	ln -frst $(DESTDIR)$(RULESDIR)/disable $(addprefix $(DESTDIR)$(RULESDIR)/,$(SYMLINKS_DISABLE))

check:
	@find local abstractions tunables -type f -printf "%p $(DESTDIR)$(RULESDIR)/%p\n" | xargs -n2 diff -qs
	@$(foreach symlink,$(shell find succeeding-boot-disable -type f -printf "%P "),find $(DESTDIR)$(RULESDIR)/disable -type l -name "$(symlink)" -printf "disable/%P is there\n";)
	@printf "\ngrep the symlink or file to check if it is there.\n"

uninstall:
	rm -f $(LOCAL)
	rm -f $(addprefix $(DESTDIR)$(RULESDIR)/,$(TUNABLES))
	rm -f $(addprefix $(DESTDIR)$(RULESDIR)/,$(ABSTRACTIONS))
	# Yes, should be careful with this one. -type d -empty is safe enough.
	find $(DESTDIR)$(RULESDIR)/tunables -type d -empty -delete -printf "deleted tunables %p\n"
	find $(DESTDIR)$(RULESDIR)/abstractions -type d -empty -delete -printf "deleted abstractions %p\n"

uninstall-disabled: uninstall
	rm -f $(addprefix $(DESTDIR)$(RULESDIR)/disable/,$(SYMLINKS_DISABLE_BOOTABLE))

uninstall-production: uninstall
	rm -f $(addprefix $(DESTDIR)$(RULESDIR)/disable/,$(SYMLINKS_DISABLE))

debug:
	echo $(ABSTRACTIONS_INSTALL)

.PHONY: all install install-disabled install-production check uninstall uninstall-disabled uninstall-production debug
