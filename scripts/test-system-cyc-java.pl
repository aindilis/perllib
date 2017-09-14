#!/usr/bin/perl -w

use Data::Dumper;

use Inline Java => <<'END_OF_JAVA_CODE',
import org.opencyc.api.CycAccess;
import static java.lang.System.out;

public class Communicate {
  public void run() {
    CycAccess cycAccess;
    try {
      cycAccess = new CycAccess();
      cycAccess.traceOn();
    }
    catch (Exception e) {
      out.println("error");
    }
    out.println("Now tracing Cyc server messages");
  }
}
END_OF_JAVA_CODE
  AUTOSTUDY => 1,
  CLASSPATH => '/var/lib/myfrdcsa/sandbox/opencyc-4.0/opencyc-4.0/api/java/lib/opencyc-4.0.140336.jar',
  EXTRA_JAVA_ARGS => '-Djava.library.path=/var/lib/myfrdcsa/sandbox/opencyc-4.0/opencyc-4.0/api/java/lib';

my $communicate = new Communicate();
$communicate->run();
