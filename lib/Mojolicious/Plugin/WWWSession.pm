package Mojolicious::Plugin::WWWSession;

use strict;
use warnings;

=head1 NAME

Mojolicious::Plugin::WWWSession - WWW:Session sessions for Mojolicious

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module allows you to overwrite the standard Mojolicious session with a WWW:Session object and enjoy all the goodies it provides

Example :

In you apllication module add the fallowing lines 

    use Mojolicious::Plugin::WWWSession;

    sub startup {
    
        ...
    
        #Overwrite session
        $self->plugin( WWWSession => { storage => [File => {path => '.'}] } );

        ...
    }


=head1 Using the session

=head2 Settings values

There are two ways you can save a value on the session :

    $session->set('user',$user);
    
    or 
    
    $session->user($user);
    
If the requested field ("user" in the example above) already exists it will be 
assigned the new value, if it doesn't it will be added.

When you set a value for a field it will be validated first (see setup_field() ). 
If the value doesn't pass validation the field will keep it's old value and the 
set method will return 0. If everything goes well the set method will return 1.

=head2 Retrieving values

    my $user = $session->get('user');
    
    or
    
    my $user = $session->user();
    
If the requested field ("user" in the example above) already exists it will return 
it's value, otherwise will return C<undef>

=head1 Possible options for the plugin

Here is an exmple containing the options you can pass to the plugin:

    {
    storage => [ 'File' => { path => '/tmp/sessions'},
                 'Memcached' => { servers => ['127.0.0.1'] }
               ],
    serialization => 'JSON',
    expires => 3600,
    fields => {
              user => {
                      inflate => sub { return Some::Package->new( $_[0] ) },
                      deflate => sub { $_[0]->id() },
                      }
              age => {
                     filter => [21..99],
                     }
    }
    
See WWW:Session for more details on possible options and on how you can use the session

If you use the "Storable" serialization engine you can store objects in the session. 
Also multiple session storage backends can be used simultaneously

=cut

use base 'Mojolicious::Plugin';

use WWW::Session;
use Digest::MD5 qw(md5_hex);

=head1 METHODS

=head2 register

Called by Mojo when you register the plugin

=cut

sub register {
    my ($self, $app, $args) = @_;

    $args ||= {};
    
    WWW::Session->import(%$args);

    my $stash_key = 'mojo.session';

    $app->hook(
        before_dispatch => sub {
            my $self = shift;

            my $sid = $self->cookie('sid') || md5_hex($$ + time() + rand(time()));

            $self->cookie(sid => $sid);

            my $session = WWW::Session->find_or_create($sid);

            $self->stash($stash_key => $session);
        }
    );

    $app->hook(
        after_dispatch => sub {
            my $self = shift;

            $self->stash($stash_key)->flush;
        }
    );
}


=head1 AUTHOR

Gligan Calin Horea, C<< <gliganh at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-wwwsession at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-WWWSession>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::WWWSession


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-WWWSession>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-WWWSession>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-WWWSession>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-WWWSession/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Gligan Calin Horea.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Mojolicious::Plugin::WWWSession
