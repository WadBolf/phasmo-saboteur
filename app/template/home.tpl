<div class="SaboteurPanel" id="SaboteurPanel" style="display: none;">
	YOU ARE THE SABOTEUR
</div>
[% IF Error != "" %]
<div class="ErrorPanel" id="ErrorPanel" >
	[% Error | html %]
</div>
[% END %]
<div class="ManageContainer">
	<div id="ManageBarInfo" class="ManageTextLarge">
		<span onClick="joinGame();" id="JoinGame" class="Link Hover">Join Game</span> 
		<span class="Divider">|</span>
		<span onClick="newGame();" id="NewGame" class="Link Hover">New Game</span>
		<span id="GameID" class="Link"></span>
	
		<div class="UserListContainer" id="UserList"></div>
	</div>
	<div id="ManageBarJoin" class="ManageTextLarge" style="display: none;">
		<span onClick="cancelPressed();" class="CancelButton">Cancel</span>
		<span><input class="InputBox" id="GameIDInput" type="text" placeholder="Game ID" /></span>
		<span onClick="joinPressed();" class="JoinButton">Join</span>

	</div>
</div>
<div class="AdminPanel" id="AdminPanel" style="display: none;">
	<span class="Link Hover" onClick="createSaboteur();">Create Saboteur</span>
	<span class="Divider">|</span>
	<span class="Link Hover" OnClick="revealSaboteur();">Reveal Saboteur</span>
</div>

<script>
	function logout()
	{
		 postIt({ "Mode": "LOGOUT" });
	}

	function newGame()
	{
		postIt({ "Mode": "NEWGAME" });
	}
	
	function joinGame()
        {
                $('#ManageBarInfo').hide(200);
                $('#ManageBarJoin').show(200);
        }

	function cancelPressed()
        {
                $('#ManageBarInfo').show(200);
                $('#ManageBarJoin').hide(200);
        }

	function createSaboteur()
	{
		postIt({ "Mode": "CREATESABOTEUR" });
	}

	function revealSaboteur()
	{
		postIt({ "Mode": "REVEALSABOTEUR" });
	}
	
	function joinPressed()
	{
		var code = $('#GameIDInput').val();
		if (code != '')
		{
			postIt({ "Mode": "JOINGAME", "GameID": code });
		}
	}


	function runApp(){
		var delay = Math.floor(Math.random() *3000) + 2000;
		get_data("GetMe",  "");
    		setTimeout(runApp, delay);
	}	

	runApp();


	function ajaxReturn(data)
	{
		console.log(data);
		if (data["mode"] == "GetMe")
		{
			if (data["User"]["game_id"] != 0)
			{

				if (data["User"]["is_saboteur"] == 1)
				{
					$('#SaboteurPanel').show(500);
				}
				else
				{
					$('#SaboteurPanel').hide(500);
				}


				if (data["User"]["is_game_admin"] == 1)
				{
					$('#AdminPanel').show(500);
				}
				else
				{
					$('#AdminPanel').hide(500);
				}

				var reveal = 0
				if (data["User"]["gamer_state"] == "REVEAL")
				{
					reveal = 1;
				}

				$('#GameID').html( '<span class="Divider">|</span>' + data["User"]["game_id"] );
				
				//list users in game
				var usersHTML = "<hr>";
				
				usersHTML += "";
				for (var n = 0; n < data["UsersInGame"].length; n++ )
				{
					var container = "UserContainer";	
					var userIcon = "user-icon.png";
					if ( data["UsersInGame"][n]["is_game_admin"] == 1)
                                        {
						userIcon = "user-icon-admin.png";
					}
 
					if (reveal == 1 &&  data["UsersInGame"][n]["is_saboteur"] == 1)
                                        {
	
						userIcon = "user-icon-evil.png";
						container = "UserContainerEvil";
						if ( data["UsersInGame"][n]["is_game_admin"] == 1)
						{
							userIcon = "user-icon-evil-admin.png";
						}
					}

					usersHTML += '<span class="' + container + '">' +
					'<img src="' + userIcon +'" height="80px">' +
					'<div>' + data["UsersInGame"][n]["gamer_tag"] + '</div>' +
					'</span>';
				}

				$('#UserList').html(usersHTML);
			}
			else
			{
				$('#GameID').html( "" );
				$('#UserList').html("");
			}
		}
	}

</script>

[% inf %]
