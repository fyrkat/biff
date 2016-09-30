NAMEDPROG=/etc/named

CFLAGS=

all: .All

.All: named.conf pz/All
	@rm -f .All
	@touch .All

named.conf: masters slaves options
	rcs -l masters slaves options
	ci -u -mEmpty masters slaves options
	env LANG=C  ./mk-conf > named.conf.new
	-mv -f named.conf named.conf.old
	mv -f named.conf.new named.conf
	chmod 444 named.conf
	/usr/sbin/rndc reconfig

pz/All: FRC
	(cd pz; $(MAKE) All)

# Ok, so .restart is misleading...
# But it's usually not neccessary to restart and throw away the cache.

.restart: named.conf
	/usr/sbin/rndc reconfig
	@rm -f .restart
	@touch .restart

allprogs: Reload Restart

Reload: Reload.c
	$(CC) $(CFLAGS) -DNAMED_PROG=\"$(NAMEDPROG)\" -o $@ $?
	chown root $@
	chmod u+s $@

Restart: Reload
	rm -f $@
	ln $? $@

clean:
	rm -f Reload Restart
FRC:
