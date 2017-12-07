# ABSTRACT: set up SmartCAT
package SmartCAT::Command::update_stores;
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
    my %documents = map { $_->{name}.'.po' => $_ } @documents;
	
    my $path = $opt->{po_path}.'/'.$opt->{project};
    opendir(DIR, $path) or die "Could not open dir '$path' $!";
    while (my $lang_dir = readdir(DIR)) {
      next if not -d ($path.'/'.$lang_dir) or $lang_dir =~ m/^\./;
      opendir(LANG_DIR, $path.'/'.$lang_dir) or die "Could not open directory $path/$lang_dir - $!";
      while (my $file = readdir(LANG_DIR)) {
        next if not -f ($path.'/'.$lang_dir.'/'.$file) or $file !~ m/\.po$/;
        if ($documents{$lang_dir.'_'.$file}) {
          my $document = $documents{$lang_dir.'_'.$file};
          $self->app->updateFile($opt->{po_path}, $opt->{project}, $opt->{token_id}, $opt->{token}, $document->{id}, $file, $lang_dir);
        }
        else {
          $self->app->uploadFile($opt->{po_path}, $opt->{project}, $opt->{token_id}, $opt->{token}, $file, $lang_dir);
        }
      }
      closedir(LANG_DIR);
    }
    closedir(DIR);
    return 1;
}

1;
