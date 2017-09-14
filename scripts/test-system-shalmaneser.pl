#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::Shalmaneser;

my $shal = System::Shalmaneser->new();
# my $text = "I am wondering what exactly this can do and how it can do it?";

# have a system for basic test texts

my $text = "This is a simple test of the system";

my $text3 = "I am tired of those who claim that good is subjective.  I
am also ntired of those who debate the practical importance of AI,
questioning whether there exists a recursive function that is
AI-complete.  People claim that AI cannot be created, because the
human mind is infinite.";

my $text4 = "What do they mean infinite?  Limitless?  Then, obviously
there is no reason they couldn't create AI.  People say that they are
not sure whether human behaviour can be represented in terms of
recursive functions.  They wonder whether recursive functions are
sufficient and AI-complete, and yet every piece of human reasoning yet
invented has been. But I won't test my arguments against them, I will
propose solutions.  There are no smart people.  There are people who
have more than others, there are the rich and the poor.  But they are
equally unable to make adequate use of their resources.  To do so
requires systematic intelligence.  Fortunately, the computer provides
us with systematic intelligence.  Because expertise may now be copied
instantly, there is no reason why anyone should go without the benefit
of expert knowledge at all times.  For instance, everyone's basic
intelligence needs ought to be met, by having a uniform Social
Security System.  The idea of the Debian Social Security System is
that expertise may now be copied instantly, and there is no reason
someone should be bereft of basic knowledge that could be taught to
them by a computer.  As such, a general purpose system which starts
from ground up, including meal planning, Currently, there is no
software available in Debian which provides for meal planning, or even
realtime life planning in general.  I argue that having these
abilities given to them will not make the person less intelligent.
Rather, I think that intelligence and motivation can be instructed.
The reason I believe this is that people can be taught with both
negative reinforcement, such as life often treats us with, but also
positive reinforcement.  There is no reason for making mistakes if
they don't have to be made.  My worldview is basically that the
universe is a problem, and is defective, for instance, thermodynamics,
etc, are all defective.  My religous view is that the afterlife is
something which is in actually accomplished by our race as transform
existing reality into an increasingly heavenlike world, until we have
replaced the earth with heaven.";

print Dumper
  ($shal->ApplyShalmaneserToText
   (Text => $text));
