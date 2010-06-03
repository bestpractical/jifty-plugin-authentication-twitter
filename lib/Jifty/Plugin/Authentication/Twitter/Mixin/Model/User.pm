use strict;
use warnings;

package Jifty::Plugin::Authentication::Twitter::Mixin::Model::User;
use Jifty::DBI::Schema;
use base 'Jifty::DBI::Record::Plugin';

=head1 NAME

Jifty::Plugin::Authentication::Twitter::Mixin::Model::User - mix twitter into a user model

=cut

use Jifty::Plugin::Authentication::Twitter::Record schema {
    column twitter_name =>
        type is 'text',
        is distinct;
};

1;

