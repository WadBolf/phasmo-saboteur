#! /usr/bin/env perl

#
# Phasmo Saboteur by Clare Jonsson (wadbolf@gmail.com) 16/01/2022
# If you use this project in any form, please keep this info here.
# Thank you.
#


# DEPENDANCIES AND LIBS -------------------------------------------------------

        use warnings;
        use strict;
        use Cwd qw(cwd);
        use CGI qw(:all);
        use CGI::Session;
        use Template qw(:template );
        use Data::Dumper;
        use DBI;
        #use Quantum::Superpositions;
        use JSON;
        # use Digest::SHA qw(sha256_hex);

# DEPENDANCIES AND LIBS -------------------------------------------------------

# SITE LOCATION----------------------------------------------------------------

        # The following within the BEGIN block is used in order to dynamically set the lib location:
        my $site_dir;
        my $lib_dir;
        my $siteLocation;
        BEGIN
        {
                $site_dir = cwd;                # Get surrent working directory
                $site_dir =~ s/htdocs//;        # remove htdocs to get the stire directory
                $site_dir = $site_dir . "app";  # Add app folder
                $lib_dir = $site_dir . "/lib";  # add "/lib" to create the lib directory
                eval "use lib('$lib_dir')";     # use lib directory
        }

        # Add Saboteur Library
        use Saboteur;

        # Set database and template-path
        my $db = "$site_dir/database/saboteur.sqlite";
        my $templatepath = "$site_dir/template";

# SITE LOCATION----------------------------------------------------------------

# CGI Setup -------------------------------------------------------------------

	# Setting return JSON to no mode in case none is found
	my $json = encode_json({
		is_error => 1,
		response => {
			error => "No Mode",
			mode  => "No Mode",
		},
	});

        my $cgi = CGI->new;
        my $session = new CGI::Session(undef, $cgi);
        my $cookie = $cgi->cookie(CGISESSID => $session->id);
        print $cgi->header( -cookie=>$cookie );

	my $params;
	if ($cgi=param())
	{

		if (uc $ENV{'REQUEST_METHOD'} eq "POST")
		{
			my @names = param();
			if (param('Mode'))
			{
				$params->{"Mode"} = param('Mode');
			}
		}
	}

        # Attempt to connect to database
        my $saboteur = new Saboteur($db) or die "Database not found";

        my $inf;
        my $userTag = "";

        #$session->param('UserName', '');

        # If not logged in, then show the Login page
        if ($session->param('UserTag') eq "")
        {
                $json = encode_json({
			is_error => 1,
			response => {
				error => "Error getting user",
				mode  => $params->{"Mode"},
			},
		});
        }
        else
        {
		$userTag = $session->param('UserTag');

		if ($params->{"Mode"} eq "CREATESABOTEUR")
                {
                        $saboteur->CreateSaboteur({
                                UserTag=> $userTag,
                        });
			$json = encode_json({
				is_error => 0,
				response => {
					mode  => $params->{"Mode"},
				},
			});
                }
	
		if ($params->{"Mode"} eq "REVEALSABOTEUR")
                {
                        $saboteur->RevealSaboteur({
                                UserTag => $userTag,
                        });
			$json = encode_json({
				is_error => 0,
				response => {
					mode  => $params->{"Mode"},
				},
			});
                }


		if ($params->{"Mode"} eq "GetMe")
		{
			my $user = $saboteur->GetUser({ Gamer_Tag => $userTag });
			if ($user->{is_error})
			{
				$json = encode_json({
					is_error => 1,
					response => {
						error => "Error getting user",
						mode  => $params->{"Mode"},
					},
				});
			}
			else
			{

				$saboteur->UpdateActivity({
					UserTag => $userTag,
				});

				my $usersInGame = {};
				if ( $user->{response}->{game_id} )
				{
					$usersInGame = $saboteur->GetGameUsers({
						GameID => $user->{response}->{game_id},
					});	

					if ( $usersInGame->{is_error} )
					{
						#$usersInGame = {};
					}
					else
					{
						$usersInGame = $usersInGame->{response};
					}
				}

				$json = encode_json({
					is_error => 0,
					response => {
						UserTag     => $userTag,
						User	    => $user->{response},
						UsersInGame => $usersInGame,
						mode	    => $params->{"Mode"}, 
					},
				});
			}
		}
        }

# CGI Setup -------------------------------------------------------------------


print $json;
exit();
