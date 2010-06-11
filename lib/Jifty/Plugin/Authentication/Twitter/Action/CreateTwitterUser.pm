use warnings;
use strict;

=head1 NAME

Jifty::Plugin::Authentication::Twitter::CreateTwitterUser

=cut

package Jifty::Plugin::Authentication::Twitter::Action::CreateTwitterUser;
use base qw/Jifty::Action/;

use Scalar::Defer 'defer';

use Jifty::Param::Schema;
use Jifty::Action schema {
    param name =>
        is mandatory,
        default is defer { Jifty->web->session->get('screen_name') };
};

=head2 take_action

Creates a user account based on Twitter credentials and the provided name.

=cut

sub take_action {
    my $self = shift;
    my $twitter_id = Jifty->web->session->get('twitter_id');
    if (!$twitter_id) {
        # Should never get here unless someone's trying weird things
        $self->result->error("Invalid verification result");
        return;
    }

    my $twitter_account = Jifty::Plugin::Authentication::Twitter::Model::TwitterAccount->new(current_user => Jifty::CurrentUser->superuser);
    my $user = Jifty->app_class('Model', 'User')->new(current_user => Jifty::CurrentUser->superuser);

    my ($ok, $msg) = $user->create(
        name => $self->argument_value('name'),
    );
    if (!$ok) {
        $self->result->error("Unable to create user: $msg");
    }

    ($ok, $msg) = $twitter_account->create(
        user_id       => $user->id,
        twitter_id    => $twitter_id,
        screen_name   => Jifty->web->session->get('screen_name'),
        access_token  => Jifty->web->session->get('access_token'),
        access_secret => Jifty->web->session->get('access_secret'),
    );

    if (!$ok) {
        $user->delete;
        $self->result->error("Unable to create user: $msg");
    }

    my $current_user = Jifty->app_class('CurrentUser')->new(user_object => $user);

    # Actually do the signin thing.
    Jifty->web->current_user($current_user);
    Jifty->web->session->expires( undef );
    Jifty->web->session->set_cookie;

    $self->report_success if not $self->result->failure;

    Jifty->web->session->remove($_)
        for qw/twitter_id screen_name access_token access_secret/;
}

sub report_success {
    my $self = shift;
    $self->result->message( _("Welcome, ") . Jifty->web->current_user->user_object->name . "." );
}

1;

