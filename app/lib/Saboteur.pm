package Saboteur;

use warnings;
use strict;

use DBI;
use MIME::Base64;
use Data::Dumper;
use HTTP::Request::Common qw{ POST };
use CGI;
use JSON;
use Digest::SHA qw(sha256);

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


sub GetUser
{
	my ( $self, $params) = @_;

	# Required Params
	my @required = q{UserName};
	foreach my $req ( @required )
	{
		if (!$params->{ $req } )
		{
			return "MISSING PARAMS: " . $req;
		}
	}


	my $q = $self->{db}->prepare( q{
                SELECT * FROM Users WHERE user_name = ?;
        } );

        if ( !defined( $q ) || !$q->execute( lc $params->{UserName} ) )
        {
                return undef;
        }

        while ( defined( my $row = $q->fetchrow_hashref ) )
        {
                return $row;
        }

	return undef;

}

sub NewUser
{
	my ( $self, $params ) = @_;

	# Required Params
        my @required = q{UserTag};
        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return {
				is_error => 1,
				response => "MISSING PARAMS: ",
			};
                }
        }

	my @set = ('0' ..'9');
	my $userTag = sprintf("%s_%s", $params->{UserTag},  join '' => map $set[rand @set], 1 .. 8 );
	my $epoch = time();

	my $q = $self->{db}->prepare( q{
                INSERT INTO Sessions
		( gamer_tag, game_id, last_activity_epoch )
		VALUES
		( ?, ?, ? )
        } );

        if ( !defined( $q ) || !$q->execute( $userTag, 0, $epoch ) )
        {
		return {
			is_error => 1,
			response => "Could not create user",
		};
        }
	
	
	return {
		is_error => 0,
		response => $userTag,
	};
}


sub EncryptString
{
	my ( $self, $params) = @_;

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
