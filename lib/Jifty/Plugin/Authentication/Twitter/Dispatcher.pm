use strict;
use warnings;

package Jifty::Plugin::Authentication::Twitter::Dispatcher;
use Jifty::Dispatcher -base;

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Dispatcher - dispatcher for Twitter plugin

=head1 DESCRIPTION

All the dispatcher rules jifty needs to support L<Jifty::Authentication::Twitter>

=head1 RULES

=head2 before '/twitter/callback'

Handles the login callback. You probably don't need to worry about this.

=cut

before qr'^/twitter/callback' => run {
    # add action

    if ( Jifty->web->request->continuation ) {
        Jifty->web->request->continuation->call;
    }
    else {
        redirect '/';
    }
};

1;

