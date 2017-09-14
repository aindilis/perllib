#!/usr/bin/perl -w

"export GATE_PATH=/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0"
"java -cp goldfish.jar:$GATE_PATH/bin/gate.jar:$GATE_PATH/bin/tools14.jar TotalGoldfishCount testFile.txt"
