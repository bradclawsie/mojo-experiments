package experiment0::Controller::API;
use Mojo::Base 'Mojolicious::Controller', -signatures;

# This action will render a template
sub welcome ($self) {

  # Render template "example/welcome.html.ep" with message
  $self->render(text => 'Welcome, here is your value:' . $self->stash('value'));
}

1;
