# Scripte für Supernodes

* ([supernode.config](supernode.config)): Konfiguration für einen Supernode nach Eulenfunk-Schema. Muss angepasst werden, die Werte gibt es von den Admins des zugerhörigen BPG-Konzentrators.
* [supernode-setup.sh](supernode-setup.sh): Gibt zur Konfiguration ([supernode.config](supernode.config)) passende */etc/network/interfaces* Abschnitte aus. Einfach copy and paste in */etc/network/interfaces* machen.
* [supernode-rc.sh](supernode-rc.sh): Startscript. Soll über /etc/rc.local aufgerufen werden. Zugehörige Konfiguration liegt im selben Ordner ([supernode.config](supernode.config))


