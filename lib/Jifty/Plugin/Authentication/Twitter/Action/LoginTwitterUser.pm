use warnings;
use strict;

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Action::LoginTwitterUser - login Twitter user

=cut

package Jifty::Plugin::Authentication::Twitter::Action::LoginTwitterUser;
use base qw/Jifty::Action/;

=head1 ARGUMENTS

=cut

use Jifty::Param::Schema;
use Jifty::Action schema {
};

=head1 METHODS

=head2 take_action

Get the session key using the Twitter API.  Check for existing user.
If none, autocreate.  Login user.

=cut

sub take_action {
    my $self = shift;

    my $name = '...';

    # Load up the user
    my $current_user = Jifty->app_class('CurrentUser');
    my $user = $current_user->new( twitter_name => $name );

    # Autocreate the user if necessary
    if ( not $user->id ) {
        my $action = Jifty->web->new_action(
            class           => 'CreateUser',
            current_user    => $current_user->superuser,
            arguments       => {
                twitter_name => $name,
            }
        );
        $action->run;

        if ( not $action->result->success ) {
            # Should this be less "friendly"?
            $self->result->error(_("Sorry, something weird happened (we couldn't create a user for you).  Try again later."));
            return;
        }

        $user = $current_user->new( twitter_name => $name );
    }

    my $u = $user->user_object;

    # Always check name
    $u->__set( column => 'twitter_name', value => $name )
        if not defined $u->twitter_name or $u->twitter_name ne $name;

    # Login!
    Jifty->web->current_user( $user );
    Jifty->web->session->expires('+1y');
    Jifty->web->session->set_cookie;

    # Success!
    $self->report_success;

    return 1;
}

=head2 report_success

=cut

sub report_success {
    my $self = shift;
    $self->result->message(_("Hi %1!", Jifty->web->current_user->user_object->twitter_name ));
}

1;

