use strict;
use warnings;

package Jifty::Plugin::Authentication::Twitter::Dispatcher;
use Jifty::Dispatcher -base;
use Net::OAuth;
use Net::OAuth::RequestTokenRequest;
use Net::OAuth::RequestTokenResponse;
use Net::OAuth::UserAuthRequest;
use Net::OAuth::UserAuthResponse;
use Net::OAuth::AccessTokenRequest;
use Net::OAuth::AccessTokenResponse;
use HTTP::Request::Common ();

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Dispatcher - dispatcher for Twitter plugin

=head1 DESCRIPTION

All the dispatcher rules jifty needs to support L<Jifty::Authentication::Twitter>

=head2 /twitter/login

Talk to Twitter to get a request token, then redirect the user to Twitter so
they can authorize it.

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

=head2 /twitter/callback

Twitter redirects the user back here after they've authorized the request
token. We have to talk to Twitter again to trade the request token for an
access token, at which point Twitter also tells us which Twitter account the
user is logged into.

If all goes well we load or create the user's account.

=cut

on '/twitter/callback' => run {
    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Twitter');
    my $request_token = Jifty->web->request->argument('oauth_token');
    my $cas_key = Jifty::CAS->key('twitter_oauth' => $request_token);
    my $request_secret = Jifty::CAS->retrieve('twitter_oauth' => $cas_key)->content;

    my $access_token_request = Net::OAuth::AccessTokenRequest->new(
        consumer_key     => $plugin->consumer_key,
        consumer_secret  => $plugin->consumer_secret,
        token            => $request_token,
        token_secret     => $request_secret,
        request_method   => 'POST',
        request_url      => 'http://twitter.com/oauth/access_token',
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => $$ * rand,
    );
    $access_token_request->sign;

    my $ua = LWP::UserAgent->new;

    my $res = $ua->request(HTTP::Request::Common::POST $access_token_request->to_url);
    if (!$res->is_success) {
        die "Something went wrong";
    }

    my $response = Net::OAuth::AccessTokenResponse->from_post_body($res->content);

    my $access_token  = $response->token;
    my $access_secret = $response->token_secret;
    my $twitter_id    = $response->extra_params->{user_id};
    my $screen_name   = $response->extra_params->{screen_name};

    my $twitter_account = Jifty::Plugin::Authentication::Twitter::Model::TwitterAccount->new(current_user => Jifty::CurrentUser->superuser);
    $twitter_account->load_by_cols(
        twitter_id => $twitter_id,
    );
    my $user = Jifty->app_class('Model', 'User')->new(current_user => Jifty::CurrentUser->superuser);

    if ($twitter_account->id) {
        $user->load($twitter_account->user_id);
        $twitter_account->set_screen_name($screen_name);
        my $current_user = Jifty->app_class('CurrentUser')->new(id => $user->id);
        Jifty->web->current_user($current_user);
        Jifty->web->session->expires( undef );
        Jifty->web->session->set_cookie;
        redirect '/';
    }
    else {
        Jifty->web->session->set(twitter_id    => $twitter_id);
        Jifty->web->session->set(screen_name   => $screen_name);
        Jifty->web->session->set(access_token  => $access_token);
        Jifty->web->session->set(access_secret => $access_secret);
        redirect '/twitter/create';
    }
};

on '/twitter/create' => run {
};

1;

