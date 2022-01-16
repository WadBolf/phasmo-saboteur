package Saboteur;

use warnings;
use strict;

use DBI;
use MIME::Base64;
use Data::Dumper;
use HTTP::Request::Common qw{ POST };
use CGI;
use JSON;

sub new
{
        my ($self, $dbfile) = @_;
        $self = {
                db => undef,
                err => "No Error",
        };

        bless $self;

        return "database file not found"
                        unless (-e $dbfile);
                $self->{db} = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {
                        AutoCommit => 1,
                        sqlite_use_immediate_transaction => 1,
                });
                return "Failed to connect to database: $DBI::errstr"
                        unless (defined($self->{db}));

        return $self;
}

sub err
{
        my ($self) = @_;
        return $self->{err};
}


sub TestGet
{

	return "HELLO";
}


1;
