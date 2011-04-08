#!/bin/sh
#
# Author:
#   z0mbix
# Description:
#   Utility to easily locate OpenBSD/FreeBSD packages for the current release
# Requirements:
#   An OpenBSD or FreeBSD system
# Notes:
#   Package index file (index.txt) format changed from 4.6 onwards
#

UNAME=`uname -s`
VERSION=`uname -r | cut -d '.' -f 1,2`
RELEASE=`uname -r`
ARCH=`uname -m`
PKGFILE="$HOME/.packages-$RELEASE"

if [ ${UNAME} = "FreeBSD" ]; then
	FTPMIRROR=ftp.uk.freebsd.org
	FTPPATH=pub/FreeBSD/releases/$ARCH/$VERSION/packages
	INDEXFILE=INDEX.bz2
elif [ ${UNAME} = "OpenBSD" ]; then
	FTPMIRROR=ftp.openbsd.org
	FTPPATH=pub/OpenBSD/$RELEASE/packages/$ARCH
	INDEXFILE=index.txt
elif [ ${UNAME} = "NetBSD" ]; then
	echo "Shouldn't you be using pkgin?"
else
	echo "You're not using FreeBSD or OpenBSD!"
	exit 1
fi

if [ $# -lt 1 ]; then
	echo "Please specify atleast one package to search for."
else
	if [ ! -f $PKGFILE ]; then
		echo "$PKGFILE does not exist, downloading..."
		if [ ${UNAME} = "FreeBSD" ]; then
			ftp -4 -V -o $PKGFILE.bz2 ftp://$FTPMIRROR/$FTPPATH/$INDEXFILE
			bunzip2 $PKGFILE.bz2
		elif [ ${UNAME} = "OpenBSD" ]; then
			ftp -4 -V -o - ftp://$FTPMIRROR/$FTPPATH/$INDEXFILE | awk '{print $10}' > $PKGFILE
		fi
		
		if [ ! -f $PKGFILE ]; then
			echo "Please manually download the file:"
			echo "$FTPMIRROR/$FTPPATH/$INDEXFILE"
			echo "and save it as:"
			echo "$PKGFILE"
			exit
		fi
	fi
	for PKG in $@; do
		echo "Results for: $PKG"
		if [ ${UNAME} = "FreeBSD" ]; then
			grep -i "^$PKG" $PKGFILE | cut -f1 -d\|
		elif [ ${UNAME} = "OpenBSD" ]; then
			grep -i "^$PKG" $PKGFILE
		else
			echo "OS?"
		fi
	done
fi
