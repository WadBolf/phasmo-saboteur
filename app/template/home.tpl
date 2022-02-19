<div class="ManageContainer">
	<div class="ManageText FloatLeft">
		<span onClick="joinGame();" id="JoinGame" class="Link Hover">Join Game</span> 
		<span class="Divider">|</span>
		 <span onClick="newGame();" id="NewGame" class="Link Hover">New Game</span>
	</div>
	<div class="ManageText FloatRight">
		[% UserTag | html %]
		<span class="Divider">|</span>
		 <span onClick="logout();" id="Logout" class="Link Hover">Logout</span>
	</div>
	<div class="ClearFloat"></div>
</div>

<script>
	function logout()
	{
		 postIt({ "Mode": "LOGOUT" });
	}
</script>



[% inf %]
