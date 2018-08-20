requires 'perl', '5.008005';
requires 'Serge';
requires 'Smartcat::App';

on 'develop' => sub {
  requires 'Dist::Milla';
  requires "Test::Perl::Critic";
};

on test => sub {
    requires 'Test::More', '0.96';
};


