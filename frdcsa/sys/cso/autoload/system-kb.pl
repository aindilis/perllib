neg(working(perllibSystemApe)).


neg(hasCapability(ollie,textToLogicConversion)).

%% EVIDENCE THAT OLLIE ISN'T USEFUL FOR textToLogicConversion

%% wrap-ollie.pl -t "classify all tasks in terms of how well they reuse code.   instance, writing a special purpose planner that does what we need, verses locating, packaging, and integrating some existing  planner."
%% Loading parser models... 
%% Initializing malt: -u file:/media/andrewdo/s3/sandbox/ollie-20160516/ollie-20160516/engmalt.linear-1.7.mco -m parse -cl off
%%   Transition system    : Projective
%%   Parser configuration : Stack
%%   Feature model        : eng-liblinear.xml
%%   Classifier           : liblinear
%%   Data Format          : /engmalt.linear-1.7/conllx.xml
%% 3.88 s
%% Loading ollie models... 1.39 s
%% Loading ollie confidence function... 0.10 s

%% Running extractor on /tmp/kC9aQIOjJt...

%% Completed in 6.69 s seconds
%% $VAR1 = {
%%           'Res' => {
%%                      'Result' => 'classify all tasks in terms of how well they reuse code.
%% 0.857: (they; reuse; code)

%% instance, writing a special purpose planner that does what we need, verses locating, packaging, and integrating some existing planner.
%% 0.547: (we; need; verses locating)
%% 0.471: (we; integrating; some existing planner)

%% ',
%%                      'Success' => 1
%%                    }
%%         };

%% + FIX DYFETS COMPUTER
%% + BRUSH YOUR TEETH, FLOSS AND MOUTHWASH NOW
%% + RECORD MEALS/VITAMIN-D
%% + TAKE VITAMIN-D/ANTI-TRIGLYCERIDE MEDICATION
%%  - Guard...
%% andrewdo@ai:~$ 
