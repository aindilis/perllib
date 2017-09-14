package Rival::XML::Smart;

use base qw(XML::Smart);

use Data::Dumper;

sub ItemsInXMLText {
  my ($self,%args) = @_;
  # return a list of all the items for a given point in the tree, in
  # XML text form

}

sub ItemsInUniqueXMLSmartObjects {
  my ($self,%args) = @_;
  # return a list of all the items for a given point in the tree, in
  # XML::Smart objects with the root at the point

}

1;
