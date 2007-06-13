NAME=auth
DESCRIPTION="Authentication"

INSTALL=/usr/bin/install

all: 
clean: 
install: install-backend install-po install-ui install-html

include /usr/share/alterator/build/po.mak
include /usr/share/alterator/build/ui2.mak
include /usr/share/alterator/build/backend.mak
include /usr/share/alterator/build/fbi.mak
include /usr/share/alterator/build/html-messages.mak

HTML_PO_TEMPLATE=ui/auth/html-messages.scm
