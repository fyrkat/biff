# Biff DNS

A DNS server setup using RCS for version control.
Run these commands on a clean NetBSD installation.


## Bootstrappping

We'll get this out of the way first.  You'll need a package manager,
and pkgin(1) is a very nice one.

		# export PKG_PATH="http://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/7.0/All/"
		# pkg_add -v pkgin

We're going to need sudo(1):

		# pkgin in sudo

Good, now we have sudo(1).  Now you can do the rest as user.

Put the whole directory (minus this file) in `/local/domain`, which is
itself a symlink to `/var/chroot/named/etc/namedb`.

		sudo ln -nfs /var/chroot/named/etc/namedb /local/domain
		sudo ln -nfs namedb/named.conf /var/chroot/named/etc/named.conf

We need a key to let the `namers` group restart named(8) via rndc(8):

		sudo /usr/sbin/rndc-confgen -a
		sudo chgrp namers /etc/rndc.key
		sudo chmod g+r /etc/rndc.key
		sudo cp /etc/rndc.key /var/chroot/named/etc/rndc.key
		sudo chgrp named /var/chroot/named/etc/rndc.key

Now, from `/local/domain`, run:

		cd /local/domain
		rm localhost loopback.v6 127
		sudo chgrp -R namers . pz Makefile masters mk-conf options proto-zone slaves
		sudo chmod g+w .
		mkdir RCS pz/RCS
		chmod +x mk-conf
		cp options named.conf
		ci -t-'Makefile' -u Makefile
		ci -t-'List of zones this server is a master for.' -u masters
		ci -t-'Script that writes named.conf.' -u mk-conf
		ci -t-'Template for named.conf.' -u options
		ci -t-'Prototype empty zone.' -u proto-zone
		ci -t-'List of zones this server is a slave for.' -u slaves
		mkdir sz
		cd pz
		chmod +x Checkin-and-Reload Fixserial Reload-zones
		date +%C%y%m%d00 >serialnumber
		ci -t-'@' -u Checkin-and-Reload
		ci -t-'@' -u Fixserial
		ci -t-'@' -u Makefile
		ci -t-'@' -u Reload-zones

We now need to start named(8).

		sudo tee -a /etc/rc.conf << EOF
		named=YES
		named_chrootdir="/var/chroot/named"
		EOF

Test that everything works as expected by running `rndc reload` twice:

		% rndc reload
		server reload successful
		% rndc reload
		server reload successful

If the second try fails, it means that **/var/chroot/named/etc/rndc.key** is not readable for named(8).
