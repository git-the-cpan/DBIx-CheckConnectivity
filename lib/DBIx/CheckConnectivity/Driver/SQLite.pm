package DBIx::CheckConnectivity::Driver::SQLite;

use warnings;
use strict;

sub system_database { }
sub not_exist_error { }

1;

__END__

=head1 NAME

DBIx::CheckConnectivity::SQLite - 

=head1 INTERFACE

=over 4

=item system_database

SQLite does not have system_database, return undef

=item not_exist_error

SQLite does not have not exist error, normally, it just create the file

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

