package SmartCAT;

use App::Cmd::Setup -app;
use Class::Load;
use Data::Dumper;
use JSON qw/encode_json/;

sub getAuthKey {
    my ($self, $token_id, $token) = @_;

    Class::Load::load_class('MIME::Base64');
    my $key = MIME::Base64::encode_base64("$token_id:$token");

    return $key;
}

sub getProjectDocuments {
    my ($self, $project, $token_id, $token) = @_;

    my $key = $self->getAuthKey($token_id, $token);

    Class::Load::load_class('LWP::UserAgent');
    Class::Load::load_class('Mojo::URL');
    Class::Load::load_class('JSON::XS');

    my $ua = LWP::UserAgent->new;

    my $url = Mojo::URL->new('https://smartcat.ai/api/integration/v1/project/'.($project));
    my $request = HTTP::Request->new('GET', $url->to_string);

    $request->header('Accept' => 'application/json');
    $request->header('Authorization' => 'Basic '.$key);

    #print $request->as_string;

    my $response = $ua->request($request);
    if ($response->is_success) {
        return @{(JSON::XS::decode_json($response->content))->{documents}};
    } else {
        die $response->status_line;
    }
}

sub getFile {
    my ($self, $token_id, $token, $file_id) = @_;

    my $key = $self->getAuthKey($token_id, $token);

    Class::Load::load_class('LWP::UserAgent');
    Class::Load::load_class('Mojo::URL');
    Class::Load::load_class('JSON::XS');

    my $ua = LWP::UserAgent->new;

    my $url = Mojo::URL->new('https://smartcat.ai/api/integration/v1/document/export');
    $url->query({documentIds => $file_id});
    my $request = HTTP::Request->new('POST', $url->to_string);

    $request->header('Accept' => 'application/json');
    $request->header('Authorization' => 'Basic '.$key);
    $request->header('Content-Length' => 0);

    #print $request->as_string;

    my $response = $ua->request($request);
    if ($response->is_success) {
        my $id = (JSON::XS::decode_json($response->content))->{id};
        my $url2 = Mojo::URL->new('https://smartcat.ai/api/integration/v1/document/export/'.($id));
        my $request2 = HTTP::Request->new('GET', $url2->to_string);

        $request2->header('Accept' => 'application/json');
        $request2->header('Authorization' => 'Basic '.$key);

        #print $request2->as_string;

        sleep 10;
        my $response2 = $ua->request($request2);
        if ($response2->is_success) {
            return $response2->decoded_content;
        } else {
            die $response2->status_line;
        }
    } else {
        die $response->status_line;
    }
}

sub saveFile {
    my ($self, $po_path, $project, $name, $target_language, $body) = @_;

    my $path = "$po_path/$project/$target_language/$name";
    print $path;
    open(my $fh, '>', $path) or die "Could not open file '$path' $!";
    binmode($fh);
    print $fh $body;
    close $fh;
    print "\ndone\n";
}

sub updateFile {
    my ($self, $po_path, $project, $token_id, $token, $documentId, $name, $target_language) = @_;

    my $key = $self->getAuthKey($token_id, $token);

    Class::Load::load_class('LWP::UserAgent');
    Class::Load::load_class('Mojo::URL');

    my $ua = LWP::UserAgent->new;

    my $url = Mojo::URL->new('https://smartcat.ai/api/integration/v1/document/update');
    $url->query({documentId => $documentId});
    my $request = HTTP::Request->new('PUT', $url->to_string);

    my $boundary = 'X';
    my @rand = ('a'..'z', 'A'..'Z');
    for (0..14) {$boundary .= $rand[rand(@rand)];}

    $request->header('Content-Type' => 'multipart/form-data; boundary='.$boundary);
    $request->header('Authorization' => 'Basic '.$key);

    my $path = "$po_path/$project/$target_language/$name";
    open(my $fh, '<:bytes', $path);
    my $size = (stat $path)[7];
    my $header = HTTP::Headers->new;
    $header->header('Content-Disposition' => 'form-data; name="'.$target_language.'_'.$name.'"; filename="'.$target_language.'_'.$name.'"');
    $header->header('Content-Type' => 'application/octetstream');
    my $file_content = HTTP::Message->new($header);
    $file_content->add_content($_) while <$fh>;
    $file_content =~ s/\012/\r\n/g;
    $request->add_part($file_content);
    close $fh;
    
    my $json_header = HTTP::Headers->new('Content-Type' => 'application/json', 'Content-Disposition' => 'form-data; name="json_update_params"');
    my $json_message = HTTP::Message->new( $json_header, encode_json( { bilingualFileImportSetings => { confirmMode => "atLastStage" } } ) );
    $request->add_part($json_message);
    #print "\n\n", '-' x 50, "\n\n", $request->as_string;
    my $response = $ua->request($request);
    sleep 2;
    #print Dumper($response);
    if ($response->is_success) {
        #print $response->content;
    } else {
        print "\n\nFailed to update file: $path";
        #print "\n\nRequest:\n".$request->as_string;
        print "\n\nResponse:\n".$response->as_string;
    }
}

sub getFiles {
    my ($self, $po_path, $project) = @_;

    my $path = "$po_path/$project";

    my $first_lang_dir;
    opendir(DIR, $path) or die "Could not open dir '$path' $!";
    while (my $lang_dir = readdir(DIR)) {
      next if ($lang_dir =~ m/^\./);
      $first_lang_dir = $lang_dir;
      last;
    }
    closedir(DIR);

    $path = "$path/$first_lang_dir";
    my @files;
    opendir(LANG_DIR, $path) or die "Could not open dir '$path' $!";
    while (my $file = readdir(LANG_DIR)) {
      if ($file =~ m/\.po$/) {
        push @files, $file;
      }
    }
    closedir(LANG_DIR);

    return @files;
}

sub uploadFile {
    my ($self, $po_path, $project, $token_id, $token, $name, $target_language) = @_;

    my $key = $self->getAuthKey($token_id, $token);

    Class::Load::load_class('LWP::UserAgent');
    Class::Load::load_class('Mojo::URL');

    my $ua = LWP::UserAgent->new;

    my $url = Mojo::URL->new('https://smartcat.ai/api/integration/v1/project/document');
    $url->query({projectId => $project});
    my $request = HTTP::Request->new('POST', $url->to_string);

    my $boundary = 'X';
    my @rand = ('a'..'z', 'A'..'Z');
    for (0..14) {$boundary .= $rand[rand(@rand)];}

    $request->header('Content-Type' => 'multipart/form-data; boundary='.$boundary);
    $request->header('Authorization' => 'Basic '.$key);

    my $path = "$po_path/$project/$target_language/$name";
    open(my $fh, '<:bytes', $path);
    my $size = (stat $path)[7];
    my $header = HTTP::Headers->new;
    $header->header('Content-Disposition' => 'form-data; name="'.$target_language.'_'.$name.'"; filename="'.$target_language.'_'.$name.'"');
    $header->header('Content-Type' => 'application/octetstream');
    my $file_content = HTTP::Message->new($header);
    $file_content->add_content($_) while <$fh>;
    $file_content =~ s/\012/\r\n/g;
    $request->add_part($file_content);
    close $fh;
    my $json_header = HTTP::Headers->new('Content-Type' => 'application/json', 'Content-Disposition' => 'form-data; name="json_upload_params"');
    my $json_message = HTTP::Message->new( $json_header, encode_json( [{ targetLanguages => [$target_language]  }] ) );
    $request->add_part($json_message);

    my $response = $ua->request($request);
    #print Dumper($response);
    if ($response->is_success) {
        #print $response->content;
    } else {
        print "\n\nFailed to upload file: $path";
        #print "\n\nRequest:\n".$request->as_string;
        print "\n\nResponse:\n".$response->as_string;
    }
}

1;
