use warnings;
use strict;

=head1 NAME

Jifty::Plugin::Authentication::Twitter::LoginViaTwitter

=cut

package Jifty::Plugin::Authentication::Twitter::Action::LoginViaTwitter;
use base qw/Jifty::Action/;

use Jifty::Param::Schema;
use Jifty::Action schema {
    param access_token =>
        is mandatory;

    param access_secret =>
        is mandatory;

    param user_id =>
        is mandatory;

    param screen_name =>
        is mandatory;
};

=head2 take_action

Logs into the linked account, creating it if it does not already exist.

=cut

sub take_action {
    my $self = shift;

    return 1;
}

=head1 SEE ALSO

L<Jifty::Plugin::Authentication::Twitter>

L<Jifty::Action>, L<Jifty::CurrentUser>

=head1 LICENSE

Jifty is Copyright 2005-2010 Best Practical Solutions, LLC.
Jifty is distributed under the same terms as Perl itself.

=cut

1;

