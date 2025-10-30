#!/usr/bin/env perl

use v5.42;
use Mojo::File qw(curfile);
use lib curfile->dirname->sibling('lib')->to_string;
use Mojolicious::Commands;

Mojolicious::Commands->start_app('experiment1');

__END__
