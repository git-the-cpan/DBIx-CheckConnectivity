package DBIx::CheckConnectivity;

use warnings;
use strict;
use Carp;

our $VERSION     = '0.01';
our $AUTO_CREATE = 0;
our $ERROR       = '';

use base 'Exporter';

our @EXPORT = qw/check_connectivity/;

use DBI;
use Params::Validate qw/:all/;
use UNIVERSAL::require;

sub check_connectivity {
    validate(
        @_,
        {
            dsn       => { type => SCALAR,  regex    => qr/^dbi:/ },
            user      => 0,
            password  => 0,
            attribute => { type => HASHREF, optional => 1 },
        }
    );
    my %args     = @_;
    my $dsn      = $args{dsn};
    my $user     = $args{user} || '';
    my $password = $args{password} || '';

    my ( $driver, $database ) = $dsn =~ m/dbi:(\w+):(?:database=)?(\w+)/;

    my $dbh =
      DBI->connect( $dsn, $user, $password,
        { RaiseError => 0, PrintError => 0 },
      );
    if ($dbh) {
        $ERROR = '';    # reset the ERROR
        return 1;
    }

    # so we have an err
    $ERROR = DBI::errstr;
    if ($AUTO_CREATE) {
        my $driver_module = __PACKAGE__ . '::Driver::' . $driver;
        $driver_module->require
          or confess "$driver is not supported yet, sorry";
        my $system_database = $driver_module->system_database;
        my $not_exist_error = $driver_module->not_exist_error;

        if ( $ERROR =~ $not_exist_error ) {

            # dbi:DriverName:database_name
            # dbi:DriverName:database_name@hostname:port
            # dbi:DriverName:database=database_name;host=host_name;port=port
            $dsn =~
s/(?<=dbi:$driver:)[^;@]*(?=([;@]?))/( ( $1 && $1 eq ';' ) ?  'database=' : '' ) . $system_database /e;
            my $dbh =
              DBI->connect( $dsn, $user, $password,
                { RaiseError => 0, PrintError => 0 },
              );
            if ( $dbh && $dbh->do("create database $database") ) {
                $ERROR = '';    # reset the ERROR
                return 1;
            }
            else {
                $ERROR .= DBI::errstr;
            }
        }
    }
    return;
}

1;

__END__

=head1 NAME

DBIx::CheckConnectivity - util to check database's connectivity


=head1 VERSION

This document describes DBIx::CheckConnectivity version 0.01


=head1 SYNOPSIS

    use DBIx::CheckConnectivity;
    if ( check_connectivity( dsn => 'dbi:mysql:database=myjifty', user => 'jifty',
            password => 'blabla' ) ) {
        print 'we can connect';
    }
    else {
        warn "can not connect: $DBIx::CheckConnectivity::ERROR";
    }

=head1 DESCRIPTION


=head1 INTERFACE

=over 4

=item check_connectivity ( dsn => $dsn, user => $user, password => $password, attribute => $attribute )

return 1 if success, undef otherwise.

if $AUTO_CREATE is set to true and the db has not been created yet, this sub will
try to create the db, return 1 if success, undef otherwise.

the error message is stored in $ERROR

=back

=head1 DEPENDENCIES

L<DBI>, L<Params::Validate>


=head1 INCOMPATIBILITIES

when we connect a SQLite source, if the db doesn't exist, DBI will try to create the db automatically, 
so even $AUTO_CREATE is set to false, connect to a non-exist SQLite source will try to create the db anyway.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

currently, only mysql, Pg and SQLite are supported.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

