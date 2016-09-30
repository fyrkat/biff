DOMAINS=\

all: All Reloaded

# Zones which only need "rndc reload", possibly because they share
# zone file with another zone mentioned above.
RELOAD_ZONES=\

.PRECIOUS: All Reloaded

All: $(DOMAINS)
	./Checkin-and-Reload $?
	@rm -f All
	@touch All

Reloaded: $(RELOAD_ZONES)
	./Reload-zones $?
	@rm -f Reloaded
	@touch Reloaded
