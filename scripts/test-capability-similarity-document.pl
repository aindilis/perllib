#!/usr/bin/perl -w

use Capability::Similarity::Document::Engine::Custom1;

use Data::Dumper;

$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/perllib";

my $documentsimilarity = Capability::Similarity::Document::Engine::Custom1->new;

if (0) {
  $documentsimilarity->LoadProjects
    (Projects => ["personal-writings"]);
  my $results = $documentsimilarity->MatchTargetDocuments
    (
     User => "andrew",
     Projects => ["personal-writings"],
     TargetDocuments => [
			 "/var/lib/myfrdcsa/datasets/personal-writings/application.txt",
			],
    );
} else {
  # create a project, using particular files
  my $files = [
	       split /\n/, `find /var/lib/myfrdcsa/codebases/releases | grep -E '\\.p[lm]\$\$'`,
	      ];
  print Dumper($files);
  $documentsimilarity->CreateProject
    (
     ProjectName => "boss",
     SourceDocuments => $files,
    );
  $documentsimilarity->LoadProjects
    (
     Projects => ["boss"],
    );
  $results = $documentsimilarity->MatchTargetDocuments
    (
     User => "andrew",
     Projects => ["boss"],
     TargetDocuments => [
			 "/var/lib/myfrdcsa/codebases/internal/do/Do/ListProcessor.pm",
			],
    );
}
