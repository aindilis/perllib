#sub ReadItemData {
#  my ($self,%args) = (shift,@_);
#  if (-f $self->ItemFile.".out" ) {
#    # here is our previous version of it, so lets copy it over
#    if (-f $self->ItemFile) {
#      # only if we should
#      my $i1 = stat($self->ItemFile.".out");
#      my $i2 = stat($self->ItemFile);
#      if ($i1->size >= $i2->size) {
#	system "cp ".$self->ItemFile.".out ".$self->ItemFile;
#      }
#    } else {
#      system "cp ".$self->ItemFile.".out ".$self->ItemFile;
#    }
#  }
#  if (-f $self->ItemFile) {
#    # read it in with data dumper
#    my $query = "cat ".$self->ItemFile;
#    $self->Items(eval(`$query`));
#  } else {
#    # it doesn't so ignore it, it will be written when we close
#    # create a new item for every item in the cache
#    my $items = {};
#    foreach my $item ($self->Cache->ListContents) {
#      my $cacheitem = $self->ItemtoCacheItem($item);
#      print "<<<$cacheitem>>>\n";
#      print $cacheitem->CID."\n";
#      $items->{$cacheitem->CID} =
#	Critic::Item->new
#	    (CID => $cacheitem->CID);
#    }
#    $self->Items($items);
#  }
#  $self->ComputeSimilarityMatrix;
#}
#
#sub WriteItemData {
#  my ($self,%args) = (shift,@_);
#  my $OUT;
#  open(OUT,">".$self->ItemFile.".out") or
#    croak "Cannot open itemfile.\n";
#  print OUT Dumper($self->Items);
#  close(OUT);
#}
#
#sub ListItems {
#  my ($self,%args) = (shift,@_);
#  return values %{$self->Items};
#}

#!/usr/bin/perl -w
