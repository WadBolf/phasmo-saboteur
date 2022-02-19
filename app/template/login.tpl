<div class="DefaultContainer">
	<br />
	<div><span><input class="InputBox" id="UserTagInput" type="text" placeholder="User Tag" /></span></div>
	<br />
	<div><span class="BigButton Green" onClick="loginClicked();">GO!</span></div>
	<br />
	<br />
</div>
<script>
	function postIt( formVars) 
	{
		var form = document.createElement("form");
		document.body.appendChild(form);
		form.method = "POST";
		form.action = "index.cgi";
		
		//const keys = Object.keys(formVars)
		
		var count  = 0;
		var element = [];
		for(var keyName in formVars)
		{
			element[count] = document.createElement("input");
	    		element[count].setAttribute("type", "hidden");
			element[count].setAttribute("name", keyName);
			element[count].setAttribute("value", formVars[keyName]);
			form.appendChild(element[count]);
			count++;
		}	
		form.submit();
	}

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
