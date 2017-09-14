package Rival::Yahoo::Search::Result;

use Moose;

has 'result' => (
		      is => 'ro',
		      isa => 'Maybe[WebService::Yahoo::BOSS::Response::Web]',
		      handles => {
				  'ClickUrl' => 'clickurl',
				  'Summary' => 'abstract',
				  'Title' => 'title',
				  'Url' => 'url',
				 },
		     );

has 'I' => (
	      is => 'ro',
	      isa => 'Int',
	     );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
