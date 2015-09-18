# BonjourBroadcaster

BonjourBroadcaster is an experiment with duplicating and rebroadcasting mDNS Bonjour advertisements on OS X, similar to the functionality provided seperately by [Network Beacon](http://www.macupdate.com/app/mac/11315/network-beacon) (which is assumedly unsupported) and [Bonjour Browser](http://www.tildesoft.com).

Common usecases are accessing Bonjour advertised services across VPNs and enterprise networks.

# Use

BonjourBroadcaster is a relatively simple, one size fits all solution for spoofing Bonjour advertisements.  If you open the Bonjour discovery panel, you can see all of the advertised services recognized by your machine (both local advertisements and otherwise) and duplicate them for rebroadcasting, or simply create your own custom services.

Import and export support is included for easy transfer between machines.

In the future, BonjourBrowser will be able to check the reachability of a given server and advertise that server's services only when reachable.
