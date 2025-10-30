package experiment1::Controller::API;
use v5.42;
use Mojo::Base 'Mojolicious::Controller';

sub get ($self) {
  $self->render(json => { hello => $self->stash('value') });
}

__END__
