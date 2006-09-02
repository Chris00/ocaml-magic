# Magic
# Copyright (C) 2005: Christophe TROESTLER
#	$Id: Makefile,v 1.4 2006/09/02 22:18:33 chris_77 Exp $	
PKGNAME		= $(shell grep name META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")
PKGVERSION	= $(shell grep version META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")

SRC_WEB		= web
SF_WEB		= /home/groups/o/oc/ocaml-magic/htdocs

include Makefile.config

OCAMLFLAGS 	= -dtypes
OCAMLOPTFLAGS	= -inline 2
OCAMLDOCFLAGS	=

SOURCES = magic.ml
INTERFACES = magic.mli
C_SOURCES = magic_stub.c
DEMOS = file.ml

DISTFILES	= README INSTALL LICENSE META debian/ \
  Makefile Makefile.config $(SOURCES) $(INTERFACES) $(C_SOURCES) $(DEMOS)

PKG_DIR		= OCaml-$(PKGNAME)-$(PKGVERSION)
PKG_TARBALL 	= $(PKG_DIR).tar.gz
ARCHIVE 	= $(shell grep "archive(byte)" META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")
XARCHIVE 	= $(shell grep "archive(native)" META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")

.PHONY: all byte opt install install-byte install-opt doc ps dist
all: byte opt
byte: $(ARCHIVE)
opt: $(XARCHIVE)
doc: html
ex: $(DEMOS:.ml=.exe) $(DEMOS:.ml=.com)

$(ARCHIVE): magic_stub.o magic.ml magic.cmi
	$(OCAMLMKLIB) -o $(basename $@) -oc $(basename $@)_stub -failsafe \
	  -lmagic -L$(MAGIC_A) $(filter %.o, $^) $(filter %.ml, $^)

$(XARCHIVE): $(ARCHIVE)
	@sleep 0


# Examples
file.exe: $(ARCHIVE) file.ml
	  $(OCAMLC) -o $@ -cclib -L. -dllpath . $^
file.com: $(XARCHIVE) file.ml
	  $(OCAMLOPT) -o $@ -cclib -L. $^

# Install
install: install-byte install-opt install-doc
install-byte: byte
	[ -d $(OCAMLLIBDIR) ] || mkdir -p $(OCAMLLIBDIR)
	cp $(ARCHIVE) $(ARCHIVE:.cma=.cmi) $(ARCHIVE:.cma=.mli) $(OCAMLLIBDIR)

install-opt: opt
	[ -d $(OCAMLLIBDIR) ] || mkdir -p $(OCAMLLIBDIR)
	cp $(XARCHIVE) $(XARCHIVE:.cmxa=.cmi) $(XARCHIVE:.cmxa=.mli) \
		$(OCAMLLIBDIR)
install-doc: doc
	[ -d $(DOCDIR) ] || mkdir -p $(DOCDIR)
	cp html/* $(DOCDIR)

# Documentation
.PHONY: html
html: html/index.html

html/index.html: $(INTERFACES) $(INTERFACES:.mli=.cmi)
	[ -d html/ ] || mkdir html
	$(OCAMLDOC) -d html -html $(OCAMLDOCFLAGS) $(INTERFACES)

# Packaging
.PHONY: dist
dist:
	[ -d $(PKG_DIR) ] || mkdir $(PKG_DIR)
	cp --preserve -r $(DISTFILES) $(PKG_DIR)
	tar --exclude "CVS" -zcvf $(PKG_TARBALL) $(PKG_DIR)
	rm -rf $(PKG_DIR)

# Release a Sourceforge tarball and publish the HTML doc 
.PHONY: web upload
web: doc
	@if [ -d html ] ; then \
	  scp -r html shell.sf.net:$(SF_WEB)/ \
	  && echo "*** Published documentation on SF" ; \
	fi
	@ if [ -d $(SRC_WEB)/ ] ; then \
	  scp $(SRC_WEB)/*.html $(SRC_WEB)/*.jpg LICENSE \
	    shell.sf.net:$(SF_WEB) \
	  && echo "*** Published web site ($(SRC_WEB)/) on SF" ; \
	fi

upload: dist
	@ if [ -z "$(PKG_TARBALL)" ]; then \
		echo "PKG_TARBALL not defined"; exit 1; fi
	echo -e "bin\ncd incoming\nput $(PKG_TARBALL)" \
	  | ncftp -p chris_77@users.sf.net upload.sourceforge.net \
	  && echo "*** Uploaded $(PKG_TARBALL) to SF"



# Caml general dependencies
.SUFFIXES: .ml .mli .cmo .cmi .cmx
%.o: %.c
	$(OCAMLC) -c -ccopt '-Wall $(CC_FLAGS)' -I $(OCAML_H) $<
%.cmi: %.mli
	$(OCAMLC) $(OCAMLFLAGS) -c $<
%.cmo: %.ml
	$(OCAMLC) $(OCAMLFLAGS) -c $<
%.cma: # Dependencies to be set elsewhere
	$(OCAMLC) -a -o $@ $(OCAMLFLAGS) $(filter %.cmo, $^)
%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<
%.cmxa: # Dependencies to be set elsewhere
	$(OCAMLOPT) -a -o $@ $(OCAMLOPTFLAGS) $(filter %.cmx, $^)

.PHONY: depend dep
dep: .depend
depend: .depend
.depend: $(wildcard *.ml) $(wildcard *.mli)
	$(OCAMLDEP) $^ > .depend

include .depend

########################################################################

.PHONY: clean dist-clean
clean:
	rm -f *~ .*~ *.{o,a} *.cm[aiox] *.cmxa *.annot *.css
	rm -f $(PKG_TARBALL)
	find . -not -name *.sh -type f -perm -u=x -exec rm -f {} \;

dist-clean: clean
	rm .depend