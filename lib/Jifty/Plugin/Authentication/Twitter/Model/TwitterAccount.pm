use strict;
use warnings;

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Model::TwitterAccount

=head1 DESCRIPTION

Represents a relation between a user and a Twitter account.

=cut

package Jifty::Plugin::Authentication::Twitter::Model::TwitterAccount;
use Jifty::DBI::Schema;

use Jifty::Record schema {

column user_id =>
  is mandatory,
  label is 'User',
  is protected;

column twitter_id =>
  is mandatory,
  is protected;

column screen_name =>
  label is 'Twitter name',
  default is '',
  type is 'varchar';

column access_token =>
  type is 'varchar';
  label is 'OAuth access token',
  is protected;

column access_secret =>
  type is 'varchar';
  label is 'OAuth access token secret',
  is protected;

column created_on =>
  type is 'date',
  filters are 'Jifty::DBI::Filter::Date',
  label is 'Created on',
  since '0.2.69',
  default is defer { DateTime->now },
  is protected;

};

=head2 current_user_can

Only root may have access to this model.

In the near future, we should allow the authorizing user to edit this account
(taking care of course that the authorizing user is not actually authed via
OAuth!)

=cut

sub current_user_can {
    my $self = shift;

    return $self->current_user->is_superuser;
}
1;


