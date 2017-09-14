#!/usr/bin/perl -w

use Capability::SpeechActClassification;

use Data::Dumper;

my $sem = Capability::SpeechActClassification->new;

my $text = "The AI I work on has nothing to do with human
intelligence, or trying to make a sentient being.  If you make that
assumption about me, that's like hearing that someone is a religious
person and then chastising them for believing in Buddha (when in fact
they might be Christian).  There are many aspects to the field of AI.
Probably the best way for you to think of this is that I work on IA,
or intelligent agents.  These are programs which are capable of
solving problems that are considered useful by people.

AI concerns itself with minimizing unnecessary psychological suffering
due to avoidable accidents.  We use techniques from logic, the same
techniques that, for instance, make optimal chess playing programs,
etc, and treat the world as a game and try to win the game, by
mathematical optimizations and proofs that bad things don't happen.
You can do this, you can make certain guarantees that certain failures
don't happen for reasons that you are in control of - of course no one
can yet control certain things, but at least you do the best you know
how to do with what you have all the time.  For instance, you won't
make bad moves at chess, you won't not know the definition of a
certain word, etc.

Anyone who thinks AI is about taking control away from people doesn't
really realize that a person and an AI together are still going to
face difficult problems, it will make us better able to avoid certain
common, unnecessary mistakes, and to help us mount higher challenges
by providing rigour in situations where it wasn't previously
available.  It will not make us lazier, it will in fact make us harder
working because we won't be burned and worn out and feel helpless
towards mistakes we know ought not happen.";

print Dumper
  ($sem->GetSpeechActs
   (Text => $text));

# $VAR1 = {
#           'Result' => [
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'make us harder
# working because we won\'t be burned and',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'help us mount higher challenges',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'make bad moves at chess,',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'make optimal chess playing programs,',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'make us better able to avoid certain',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'I work on IA,',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Event',
#                           'Item' => 'available.',
#                           'Mode' => 'Assign'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'you do the best you know',
#                           'Mode' => 'Request'
#                         },
#                         {
#                           'Type' => 'Task',
#                           'Item' => 'You can do this, you can make certain guarantees that certain failures',
#                           'Mode' => 'Suggest'
#                         }
#                       ],
#           'Success' => 1
#         }
