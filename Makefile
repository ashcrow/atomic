# Installation directories.
PREFIX ?= $(DESTDIR)/usr
SYSCONFDIR ?= $(DESTDIR)/etc/sysconfig
PROFILEDIR ?= $(DESTDIR)/etc/profile.d
PYTHON ?= /usr/bin/python
PYLINT ?= /usr/bin/pylint
PEP8 ?= /usr/bin/pep8
GO_MD2MAN ?= /usr/bin/go-md2man

.PHONY: all
all: python-build docs check

.PHONY: test
test:
	sh ./test.sh

.PHONY: python-build
python-build:
	$(PYTHON) setup.py build

.PHONY: pylint-check
pylint-check:
	$(PYLINT) -E --additional-builtins=_ *.py atomic Atomic tests/unit/*.py

.PHONY: pep8-check
pep8-check:
	find . -name "*.py" | xargs $(PEP8)

.PHONY: check
check: pylint-check pep8-check

MANPAGES_MD = $(wildcard docs/*.md)

docs/%.1: docs/%.1.md
	$(GO_MD2MAN) -in $< -out $@.tmp && touch $@.tmp && mv $@.tmp $@

.PHONY: docs
docs: $(MANPAGES_MD:%.md=%)

.PHONY: clean
clean:
	$(PYTHON) setup.py clean
	-rm -rf dist build *~ \#* *pyc .#* docs/*.1

.PHONY: install-only
install-only:
	$(PYTHON) setup.py install --install-scripts /usr/share/atomic `test -n "$(DESTDIR)" && echo --root $(DESTDIR)`

	install -d -m 0755 $(DESTDIR)/usr/bin
	ln -fs ../share/atomic/atomic $(DESTDIR)/usr/bin/atomic

	install -d -m 0755 $(DESTDIR)/usr/libexec/atomic
	install -m 0755 migrate.sh gotar $(DESTDIR)/usr/libexec/atomic

	[ -d $(SYSCONFDIR) ] || mkdir -p $(SYSCONFDIR)
	install -m 644 atomic.sysconfig $(SYSCONFDIR)/atomic

	[ -d $(PROFILEDIR) ] || mkdir -p $(PROFILEDIR)
	install -m 644 atomic.sh $(PROFILEDIR)

	install -d $(PREFIX)/share/man/man1
	install -m 644 $(basename $(MANPAGES_MD)) $(PREFIX)/share/man/man1

	echo ".so man1/atomic-push.1" > $(PREFIX)/share/man/man1/atomic-upload.1

.PHONY: install
install: all install-only
