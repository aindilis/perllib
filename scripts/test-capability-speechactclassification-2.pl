#!/usr/bin/perl -w

use Capability::SpeechActClassification;

use Data::Dumper;

my $sem = Capability::SpeechActClassification->new;
$sem->StartServer();

my $text = "The task of processing AI-related Natural Language
Processing tasks was too much for me today.  There is something
seriously, seriously wrong with me Andy.  And I don't know what it is.
All I have are guesses.

I have been thinking I would probably get linux/your AI set up at my
house faster if you wanted to set up the whole thing.  My only
objection is that it will take too much brainpower right now.

It will also take significant brainpower for me to understand enough
to get started trying it out but that seems to be a more reasonable
expectation than having to do that and having to set up multiple
unknown systems.

Now that I am back at work would it be a good time for you to make
some suggestions as to what to do now that my attempt to install linux
here has failed?  I forgot what was wrong with it but I sent an email
a while ago you could probably find.  AKA please save me because
windows 7 sucks arse.";

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
