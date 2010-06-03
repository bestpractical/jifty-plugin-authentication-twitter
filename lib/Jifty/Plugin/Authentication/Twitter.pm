use strict;
use warnings;

package Jifty::Plugin::Authentication::Twitter;
use base qw/Jifty::Plugin/;

our $VERSION = '0.01';

=head1 NAME

Jifty::Plugin::Authentication::Twitter - Twitter authentication plugin for Jifty

=head2 DESCRIPTION

Provides standalone Twitter authentication for your Jifty application.
It adds the column C<twitter_name> to your User model.

=head1 SYNOPSIS

First you must tell Twitter about your application at
L<http://twitter.com/oauth_clients>. Make sure that the Callback URL is set to
C<http://your.app/twitter/callback> and that you enable "Use Twitter for login".

After that, add this plugin, filling in
the consumer key and consumer secret fields in your F<etc/config.yml> under the
C<framework> section:

    Plugins:
        - Authentication::Twitter:
            consumer_key: xxx
            consumer_secret: xxx

In your User model, you'll need to include the line

    use Jifty::Plugin::Authentication::Twitter::Mixin::Model::User;

B<after> your schema definition (which may be empty).  You may also wish
to include

See L<Jifty::Plugin::Authentication::Twitter::View> for the provided templates
and L<Jifty::Plugin::Authentication::Twitter::Dispatcher> for the URLs handled.

=cut

our %CONFIG = ( );

=head2 init

=cut

sub init {
    my $self = shift;
    %CONFIG  = @_;
}

=head1 AUTHOR

Shawn M Moore

=head1 LICENSE

Copyright 2010 Best Practical Solutions, LLC.

This program is free software and may be modified and distributed under the same terms as Perl itself.

=cut

1;

