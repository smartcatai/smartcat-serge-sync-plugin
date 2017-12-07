# ABSTRACT: set up SmartCAT
package SmartCAT::Command::sync_stores;
use SmartCAT -command;
use Class::Load;
use Data::Dumper;

sub opt_spec {
    return (
        [ 'po_path:s'  => 'Path to the po files' ],
        [ 'project:s'  => 'Id of the project' ],
        [ 'token_id:s' => 'An id of SmartCAT account' ],
        [ 'token:s'    => 'API token' ],
    )
}

sub execute {
  my ($self, $opt, $args) = @_;

  my @documents = $self->app->getProjectDocuments($opt->{project}, $opt->{token_id}, $opt->{token});

  foreach my $document (@documents) {
      my $body = $self->app->getFile($opt->{token_id}, $opt->{token}, $document->{id});
      $body =~ s/\r\n/\012/g;
      my $name = $document->{name}.'.po';
      my $target_language = $document->{targetLanguage};
      $name =~ s/^$target_language\_//;
      $self->app->saveFile($opt->{po_path}, $opt->{project}, $name, $target_language, $body);
  }
}

1;
