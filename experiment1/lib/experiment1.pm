package experiment1;
use v5.42;
use Mojo::Base 'Mojolicious';

sub startup ($self) {
  $self->helper(st => sub($c) {
    state $v = 99;
    return $v;
  });

  my $r = $self->routes;

  my $api = $r->under('/api' => 
    sub ($c) {
      $c->stash(value => 2000);
      return true;
    },
  );

  $r->get('/')->to('Example#get');
  $api->get('/')->to('API#get');
}

__END__
