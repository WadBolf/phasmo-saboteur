<div class="DefaultContainer">
	<br />
	<div><span><input class="InputBox" id="UserTagInput" type="text" placeholder="User Tag" /></span></div>
	<br />
	<div><span class="BigButton Green" onClick="loginClicked();">LETS GO!</span></div>
	<br />
	<br />
</div>
<script>
	function loginClicked()
	{
		var userTagInput = $('#UserTagInput').val();
			
		if (!userTagInput)
		{
			console.log("NO");
		}
		else
		{
			postIt({ "Mode": "LOGIN", "UserTag": userTagInput });
		}
	}
</script>

[% inf %]
