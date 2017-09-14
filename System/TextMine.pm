package System::TextMine;

# use Data::Dumper;
# use TextMine::DbCall;
# use TextMine::Entity qw/get_etype entity_ex/;
# use TextMine::Quanda    qw(get_qcat);

# use Class::MethodMaker
#   new_with_init => 'new',
#   get_set       =>
#   [

#    qw / DBH /

#   ];

# sub init {
#   my ($self,%args) = @_;
#   my ($dbh) = TextMine::DbCall->new
#      (
#       'Host' => 'localhost',
#       'Dbname' => "tm",
#       'Userid' => 'tmadmin',
#       'Password' => 'tmpass',
#      );
#   $self->DBH($dbh);
# }

# sub NamedEntities {
#   my ($self,%args) = @_;
#   my $text = $args{Text};
#   return entity_ex(\$text, $self->DBH);
# }

# sub CategorizeQuestion {
#   my ($self,%args) = @_;
#   return get_qcat($args{Question}, $self->DBH);
# }

1;


