package experiment0;
use v5.42;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Define a helper
  $self->helper(st => sub($c) {
    state $v = 99;
    return $v;
  });

  # Router
  my $r = $self->routes;

  my $api = $r->under('/api/user' => 
    sub ($c) {
      $c->stash(value => 2000);
      return true;
    });

  # Normal route to controller
  $r->get('/')->to('Example#welcome');
  $api->get('/')->to('API#welcome');
}

1;
