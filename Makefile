MANDIR = $(DESTDIR)/usr/share/man/man1
BINDIR = $(DESTDIR)/usr/bin

.PHONY: install
install:
	mkdir -p $(MANDIR)
	mkdir -p $(BINDIR)
	cp git-rebase-patch.sh $(BINDIR)/git-rebase-patch
	cp git-rebase-patch.1 $(MANDIR)/git-rebase-patch.1
	gzip -f $(MANDIR)/git-rebase-patch.1

.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/git-rebase-patch
	rm -f $(MANDIR)/git-rebase-patch.1.gz
