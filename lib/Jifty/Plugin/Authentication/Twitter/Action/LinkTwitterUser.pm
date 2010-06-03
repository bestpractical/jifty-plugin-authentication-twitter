use warnings;
use strict;

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Action::LinkTwitterUser - link Twitter user to current user

=cut

package Jifty::Plugin::Authentication::Twitter::Action::LinkTwitterUser;
use base qw/Jifty::Action/;

=head1 ARGUMENTS

=cut

use Jifty::Param::Schema;
use Jifty::Action schema {
};

=head1 METHODS

=head2 take_action

Get the session key using the Twitter API.  Link to current user.

=cut

sub take_action {
    my $self     = shift;

    if ( not Jifty->web->current_user->id ) {
        $self->result->error(_("You must be logged in to link your user to your Twitter account."));
        return;
    }

    my $user = Jifty->web->current_user->user_object;

    my $name = 'xxx';

    # Set data
    $user->__set( column => 'twitter_name', value => $name );

    # Success!
    $self->report_success;

    return 1;
}

=head2 report_success

=cut

sub report_success {
    my $self = shift;
    $self->result->message(_("Your account has been successfully linked to your Twitter user %1!", Jifty->web->current_user->user_object->twitter_name ));
}

1;

