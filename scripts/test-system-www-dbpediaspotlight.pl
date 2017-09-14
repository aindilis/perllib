#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::WWW::DBpediaSpotlight;

my $dbpediaspotlight = System::WWW::DBpediaSpotlight->new();

my $res = $dbpediaspotlight->ProcessTextWithDBpediaSpotlight
  (
   Text => "This paper describes a tableau-based higher-order theorem prover Hot and an application
to natural language semantics. In this application, Hot is used to prove equivalences using
world knowledge during higher-order uni cation (HOU). This extended form of HOU is used
to compute the licensing conditions for corrections.
1 Introduction
Mechanized reasoning systems have many applications in Computational Linguistics. Based on the
observation that some phenomena of natural language can be modeled as deductive processes, rst-
order theorem provers or related inference systems have been used for instance in phonology 2],
generation 17] and semantic analysis 22]. 11] describes an abductive framework for natural
language understanding that includes world knowledge into the semantics construction process.
Other approaches use higher-order logics and in particular -reduction and higher-order uni -
cation (HOU) as inference procedures. Following Montague 18] who has used the typed -calculus
as a semantic representation language in order to achieve compositional semantics construction,
Dalrymple, Shieber and Pereira 3] model resolution processes by representing semantically under-
speci ed elements (e.g. anaphoric references or ellipses) by free variables whose value is determined
by solving higher-order equations (see section 1.1).
Higher-order theorem provers combine logical proof search with HOU. These systems are mo-
tivated by the fact that many mathematical problems, such as Cantor's theorem, can be expressed
very elegantly in higher-order logic, but lead to an exhaustive and un-intuitive formulation when
coded in rst-order logic. Recent experiments with set theoretical problems have shown that au-
tomated higher-order theorem provers can outperform prominent high-speed rst-order theorem
provers in such cases.
In this paper, we present the tableau-based higher-order theorem prover Hot and a linguistic
application that combines the strengths of the rst-orderapproaches(inclusion of world knowledge)
with those of the higher-order ones. Before we present the theorem prover let us get an intuition
for our linguistic application.
",
  );

print Dumper($res);
