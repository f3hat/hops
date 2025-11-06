PREFIX      ?= /usr/local
BINDIR      := $(PREFIX)/bin
MANDIR      := $(PREFIX)/share/man/man1
INSTALL     := install
INSTALL_BIN := $(INSTALL) -m 755
INSTALL_MAN := $(INSTALL) -m 644

NAME        := hops
VERSION     := $(shell grep -oP 'VERSION="\K[^"]+' hops.sh)
DISTDIR     := $(NAME)-$(VERSION)
DISTFILES   := AUTHORS COPYING hops.1 hops.sh Makefile

.PHONY: all install uninstall clean dist verify help

all:
	@echo "Nothing to build. Try 'make install', 'make dist', or 'make help'."

install:
	@echo "Installing $(NAME) to $(DESTDIR)$(BINDIR)..."
	$(INSTALL) -d "$(DESTDIR)$(BINDIR)"
	$(INSTALL_BIN) hops.sh "$(DESTDIR)$(BINDIR)/$(NAME)"
	@echo "Installing man page to $(DESTDIR)$(MANDIR)..."
	$(INSTALL) -d "$(DESTDIR)$(MANDIR)"
	$(INSTALL_MAN) hops.1 "$(DESTDIR)$(MANDIR)/hops.1"

uninstall:
	@echo "Removing $(DESTDIR)$(BINDIR)/$(NAME)..."
	rm -f "$(DESTDIR)$(BINDIR)/$(NAME)"
	@echo "Removing $(DESTDIR)$(MANDIR)/hops.1..."
	rm -f "$(DESTDIR)$(MANDIR)/hops.1"

clean:
	@echo "Cleaning up..."
	rm -rf "$(DISTDIR)" "$(DISTDIR).tar.gz" "$(DISTDIR).tar.gz.sha256"

dist:
	@echo "Creating distribution tarball..."
	mkdir -p "$(DISTDIR)"
	cp -a $(DISTFILES) "$(DISTDIR)/"
	tar czf "$(DISTDIR).tar.gz" "$(DISTDIR)"
	rm -rf "$(DISTDIR)"
	@echo "Generating SHA256 checksum..."
	sha256sum "$(DISTDIR).tar.gz" > "$(DISTDIR).tar.gz.sha256"
	@echo "Created: $(DISTDIR).tar.gz and $(DISTDIR).tar.gz.sha256"

verify:
	@echo "Verifying SHA256 checksum..."
	sha256sum -c "$(DISTDIR).tar.gz.sha256"

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  install     Install script and manpage"
	@echo "  uninstall   Remove installed files"
	@echo "  dist        Create tarball and .sha256 checksum"
	@echo "  verify      Verify tarball integrity"
	@echo "  clean       Remove temporary files"
	@echo "  help        Show this help message"

