use strict;
use warnings;

package Jifty::Plugin::Authentication::Twitter::Dispatcher;
use Jifty::Dispatcher -base;
use Net::OAuth;
use Net::OAuth::RequestTokenRequest;
use Net::OAuth::RequestTokenResponse;
use Net::OAuth::UserAuthRequest;
use Net::OAuth::UserAuthResponse;
use HTTP::Request::Common ();

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Dispatcher - dispatcher for Twitter plugin

=head1 DESCRIPTION

All the dispatcher rules jifty needs to support L<Jifty::Authentication::Twitter>

=cut

on '/twitter/login' => run {
    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Twitter');
    my $request_token_request = Net::OAuth::RequestTokenRequest->new(
        consumer_key     => $plugin->consumer_key,
        consumer_secret  => $plugin->consumer_secret,
        request_method   => 'POST',
        request_url      => 'http://twitter.com/oauth/request_token',
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => $$ * rand,
    );
    $request_token_request->sign;

    my $ua = LWP::UserAgent->new;

    my $res = $ua->request(HTTP::Request::Common::POST $request_token_request->to_url);
    if (!$res->is_success) {
        die "Something went wrong";
    }

    my $response = Net::OAuth::RequestTokenResponse->from_post_body($res->content);

    # keep track of the token secret between requests
    Jifty::CAS->publish('twitter_oauth' => $response->token, $response->token_secret);

    my $auth_request = Net::OAuth::UserAuthRequest->new(
        consumer_key     => $plugin->consumer_key,
        consumer_secret  => $plugin->consumer_secret,
        token            => $response->token,
        request_method   => 'POST',
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => $$ * rand,
    );

    my $url = $auth_request->to_url('http://twitter.com/oauth/authenticate');

    Jifty->handler->buffer->clear;
    my $web_response = Jifty->web->response;
    $web_response->header( Location => $url );
    $web_response->status( 302 );

    # cookie has to be sent or returning from continuations breaks
    Jifty->web->session->set_cookie;

    Jifty::Dispatcher::_abort();
};

on '/twitter/callback' => run {
    my $token = Jifty->web->request->argument('oauth_token');
    my $secret = Jifty::CAS->key('twitter_oauth' => $token);
};

1;

