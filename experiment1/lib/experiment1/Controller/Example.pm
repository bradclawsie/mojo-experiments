package experiment1::Controller::Example;
use v5.42;
use Mojo::Base 'Mojolicious::Controller';

sub get ($self) {
  # value from the st helper
  $self->render(json => { hello => $self->st });
}

__END__
