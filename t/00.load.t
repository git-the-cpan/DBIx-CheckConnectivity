use Test::More tests => 4;

BEGIN {
use_ok( 'DBIx::CheckConnectivity' );
use_ok( 'DBIx::CheckConnectivity::Driver::Pg' );
use_ok( 'DBIx::CheckConnectivity::Driver::mysql' );
use_ok( 'DBIx::CheckConnectivity::Driver::SQLite' );
}

diag( "Testing DBIx::CheckConnectivity $DBIx::CheckConnectivity::VERSION" );
