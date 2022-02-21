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

sub CheckGameExists
{
	my ( $self, $params) = @_;

        # Required Params
        my @required = q{GameID};
        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return "MISSING PARAMS: " . $req;
                }
        }

	my $q = $self->{db}->prepare( q{
                SELECT * FROM Sessions WHERE game_id = ?;
        } );

        if ( !defined( $q ) || !$q->execute( $params->{GameID} ) )
        {
                return {
                        is_error => 1,
                        response => "Error Getting Games",
                };
        }

        while ( defined( my $row = $q->fetchrow_hashref ) )
        {
                return {
                        is_error => 0,
                        response => 1,
                };
        }

	return {
		is_error => 0,
		response => 0,
	};

}

sub JoinGame
{
	my ( $self, $params) = @_;

        # Required Params
        my @required = ("UserTag", "GameID");


        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return "MISSING PARAMS: " . $req;
                }
        }

	my $q = $self->{db}->prepare( q{
                UPDATE Sessions set game_id = ?, is_saboteur = 0, is_game_admin = 0 WHERE gamer_tag = ?;
        } );

        if ( !defined( $q ) || !$q->execute( $params->{GameID}, $params->{UserTag} ) )
        {
                return {
                        is_error => 1,
                        response => "Error Setting GameID",
                };
        }

        return {
                is_error => 0,
                response => "OK",
        };

	

}


sub RevealSaboteur
{
	my ( $self, $params) = @_;

        # Required Params
        my @required = q{UserTag};
        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return "MISSING PARAMS: " . $req;
                }
        }

	my $user = $self->GetUser({
                Gamer_Tag => $params->{UserTag},
        });

        if ($user->{is_error})
        {
                return {
                        is_error => 1,
                        response => "Error getting user",
                };
        }

	my $q = $self->{db}->prepare( q{
		UPDATE Sessions
		SET
		gamer_state = "REVEAL"
		WHERE game_id = ?
	} );

	if ( !defined( $q ) || !$q->execute( $user->{response}->{game_id} ) )
	{
		return {
			is_error => 1,
			response => "Could not update saboteur",
		};
	}

	return{
		is_error => 0,
		response => "OK",
	};

}

sub CreateSaboteur
{
	 my ( $self, $params) = @_;

        # Required Params
        my @required = q{UserTag};
        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return "MISSING PARAMS: " . $req;
                }
        }

	my $user = $self->GetUser({
        	Gamer_Tag => $params->{UserTag},
	});

	if ($user->{is_error})
	{
		return {
			is_error => 1,
			response => "Error getting user",
		};
	}

	my $usersReturn = $self->GetGameUsers({ 
		GameID => $user->{response}->{game_id},
	});
	
	if ($usersReturn->{is_error})
	{
		return {
			is_error => 1,
			response => "Error getting game users",
		};
	}

	my $gameUsers = $usersReturn->{response};
 	
	my $saboteur = int(rand(scalar @{$gameUsers}));
	my $selectedUser = $gameUsers->[$saboteur]->{gamer_tag};
	my $count = 0;
	foreach my $usr ( @{$gameUsers} )
	{
		my $set = 0;
		if ($count == $saboteur)
		{
			$set = 1;
		} 
		my $q = $self->{db}->prepare( q{
			UPDATE Sessions
			SET 
			is_saboteur = ?,
			gamer_state = "PLAYING"
			WHERE gamer_tag = ?
		} );

		if ( !defined( $q ) || !$q->execute( $set, $usr->{gamer_tag} ) )
		{
			return {
				is_error => 1,
				response => "Could not update saboteur",
			};
		}
		$count++;
	}

	return {
		is_error => 0,
		response => "OK",
	};
}


sub GetGameUsers
{
	my ( $self, $params) = @_;

        # Required Params
        my @required = q{GameID};
        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return "MISSING PARAMS: " . $req;
                }
        }

	my $q = $self->{db}->prepare( q{
                SELECT * FROM Sessions WHERE game_id = ? ORDER BY gamer_tag  ASC;
        } );

        if ( !defined( $q ) || !$q->execute( $params->{GameID} ) )
        {
                return {
                        is_error => 1,
                        response => "Error Getting Users",
                };
        }

	my @gameUsers;

        while ( defined( my $row = $q->fetchrow_hashref ) )
        {
		push( @gameUsers, $row );
        }
	
	return {
		is_error => 0,
		response => \@gameUsers,
	};
}

sub NewGame
{
	my ( $self, $params) = @_;

	# Required Params
        my @required = q{UserTag};
	foreach my $req ( @required )
	{
		if (!$params->{ $req } )
		{
			return "MISSING PARAMS: " . $req;
		}
	}

	my $userReturn = $self->GetUser({ 'Gamer_Tag' => $params->{UserTag} });

        if (!$userReturn->{is_error})
        {
                if ( $userReturn->{response}->{is_game_admin} )
                {
                        my $q = $self->{db}->prepare( q{
                                UPDATE Sessions
                                SET game_id = 0,
				is_saboteur = 0
                                WHERE game_id = ?
                        } );

                        if ( !defined( $q ) || !$q->execute( $userReturn->{response}->{game_id} ) )
                        {
                                return {
                                        is_error => 1,
                                        response => "Could update Game IDs",
                                };
                        }

                }
        }


	my @set = ('0' ..'9');
	my $gameID = join '' => map $set[rand @set], 1 .. 4 ;

	my $q = $self->{db}->prepare( q{
                UPDATE Sessions set game_id = ?, is_saboteur = 0, is_game_admin = 1 WHERE gamer_tag = ?;
        } );

        if ( !defined( $q ) || !$q->execute( $gameID, $params->{UserTag} ) )
        {
		return {
			is_error => 1,
			response => "Error Setting GameID",
		};
        }

	return {
		is_error => 0,
		response => "OK",
	};
}

sub GetUser
{
	my ( $self, $params) = @_;

	# Required Params
	my @required = ("Gamer_Tag");
	foreach my $req ( @required )
	{
		if (!$params->{ $req } )
		{
			return "MISSING PARAMS: " . $req;
		}
	}


	my $q = $self->{db}->prepare( q{
                SELECT * FROM Sessions WHERE gamer_tag = ?;
        } );

        if ( !defined( $q ) || !$q->execute( $params->{Gamer_Tag} ) )
        {
		return {
			is_error => 1,
			response => "Error Getting User",
		};
        }

        while ( defined( my $row = $q->fetchrow_hashref ) )
        {
                return {
			is_error => 0,
			response => $row,
		};
        }

	return {
		is_error => 1,
		response => "User Not Found",
	};

}

# Purge users that haven't had any activity for longer than an hour
sub Cleanup
{
	my ( $self, $params ) = @_;

	my $epoch = time() - 7200;
		
	my $q = $self->{db}->prepare( q{
                DELETE FROM Sessions
                WHERE last_activity_epoch < ?
        } );

        if ( !defined( $q ) || !$q->execute( $epoch ) )
        {
                return {
                        is_error => 1,
                        response => "Could not delete user ". $params->{UserTag},
                };
        }
}

sub LogOutUser
{
	my ( $self, $params ) = @_;

        # Required Params
        my @required = ("UserTag");
        foreach my $req ( @required )
        {
                if (!$params->{ $req } )
                {
                        return {
                                is_error => 1,
                                response => "MISSING PARAMSs: ". $req,
                        };
                }
        }

	my $userReturn = $self->GetUser({ 'Gamer_Tag' => $params->{UserTag} });

	if (!$userReturn->{is_error})
	{
		if ( $userReturn->{response}->{is_game_admin} )
		{
			my $q = $self->{db}->prepare( q{
				UPDATE Sessions
				SET game_id = 0
				WHERE game_id = ?
			} );

			if ( !defined( $q ) || !$q->execute( $userReturn->{response}->{game_id} ) )
			{
				return {
					is_error => 1,
					response => "Could update Game IDs",
				};
			}

		}
	}

	my $q = $self->{db}->prepare( q{
                DELETE FROM Sessions 
		WHERE gamer_tag = ? 
        } );

        if ( !defined( $q ) || !$q->execute( $params->{UserTag} ) )
        {
                return {
                        is_error => 1,
                        response => "Could not delete user ". $params->{UserTag},
                };
        }

	return {
		is_error => 0,
		response => "OK",
	};
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
