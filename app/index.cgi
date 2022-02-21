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
	#use Digest::SHA qw(sha256_hex);

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

        my $cgi = CGI->new;
        my $session = new CGI::Session(undef, $cgi);
        my $cookie = $cgi->cookie(CGISESSID => $session->id);
        print $cgi->header( -cookie=>$cookie );

        # Attempt to connect to database
        my $saboteur = new Saboteur($db) or die "Database not found";

	my $inf;
	my $page = "Home";
	my $userTag = "";
	my $error = "";

	#$session->param('UserName', '');

	my $ipAddress = $ENV{REMOTE_ADDR};

	# If not logged in, then show the Login page
       	if ($session->param('UserTag') eq "")
	{
		$page = "Login";
	}
	else
	{
		$userTag = $session->param('UserTag');
	}

# CGI Setup -------------------------------------------------------------------



# Do The Stuff ----------------------------------------------------------------

	if ( $cgi->param() )
	{
		my $mode = $cgi->param("Mode");

		if ($mode eq "CREATESABOTEUR")
		{
			my $return = $saboteur->CreateSaboteur({
				UserTag=> $userTag,
			});
			$page = "Reload";
		}

		if ($mode eq "REVEALSABOTEUR")
		{
			my $return = $saboteur->RevealSaboteur({
				UserTag => $userTag,
			});
			$page = "Reload";
		}

		if ($mode eq "LOGOUT")
		{
			my $return = $saboteur->LogOutUser({ 
				UserTag => $userTag,
			});
			
			$session->param('UserTag', "");
                        $userTag = "";
			$page = "Login";
		}


		if ($mode eq "NEWGAME")
		{
			my $return = $saboteur->NewGame({
				UserTag => $userTag,
			});
			$page = "Reload";
		}

		if ($mode eq "JOINGAME")
		{
			my $gameID =  $cgi->param("GameID");
		
			my $return = $saboteur->CheckGameExists({ GameID => $gameID });
			
			if ($return->{response} != 1)
			{
				$error = "Game Not Found";
			}
			else
			{
				my $return = $saboteur->JoinGame({ 
					UserTag => $userTag, 
					GameID => $gameID 
				});

				$page = "Reload";
			}
		}


		if ($mode eq "LOGIN")
		{
			$userTag =  $cgi->param("UserTag");

			if (!$userTag)
			{
				#$error = "User Tag Missing";
			}
			else
			{
				my $return = $saboteur->NewUser({
					UserTag => $userTag,
				});
			
				if ( $return->{is_error} )
				{
					#$error = "New User Failed";
				}
				else
				{
					$userTag = $return->{response};
					$page = "Reload";
					$session->param('UserTag', $return->{response});
					# Setting page to reload to update session and clear form post
				}
			}
		}
	}#
	else
	{
		#$error = "NO Response";
	}
	
# Do The Stuff ----------------------------------------------------------------


# TEMPLATE START --------------------------------------------------------------

        # Launch the template.
        my $template = Template->new({
                RELATIVE => 1,
                INCLUDE_PATH => $templatepath,
        });

        my $device = "Desktop";
        my $userAgent = $ENV{'HTTP_USER_AGENT'};
        if ( index($userAgent, "Mobile") != -1 or index($userAgent, "Android") != -1   ) {
                $device = "Mobile";
        }

	$saboteur->Cleanup();

        my $template_vars = {
                DeviceType      => $device,
                RemoteAddress   => $ENV{REMOTE_ADDR},
		Page		=> $page,
		UserTag		=> $userTag, 
		Error		=> $error,
		inf		=> $inf,
        };

	# printf ("<pre>%s</pre>", Dumper($template));

        $template->process('index.tpl', $template_vars)
                || die "Template process failed: ", $template->error(), "\n";

# TEMPLATE END ----------------------------------------------------------------

