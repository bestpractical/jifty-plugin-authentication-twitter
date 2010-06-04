use strict;
use warnings;

package Jifty::Plugin::Authentication::Twitter::Dispatcher;
use Jifty::Dispatcher -base;
use Net::OAuth;

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

on '/twitter/login' => run {
    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Twitter');
    my $request_token_request = Net::OAuth->request("request token")->new(
        consumer_key     => $plugin->consumer_key,
        consumer_secret  => $plugin->consumer_secret,
        request_url      => 'http://twitter.com/oauth/request_token',
        request_method   => 'POST',
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => $$ * rand,
    );
};

1;

