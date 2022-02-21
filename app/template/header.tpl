<div class="HeaderContainer">
	<img height="120px" src="Logo.png">
	[% IF UserTag != "" %]
		<hr>
		<div class="ManageText">
			[% UserTag | html %]
			<span class="Divider">|</span>
			 <span onClick="logout();" id="Logout" class="Link Hover">Logout</span>
		</div>
	[% END %]
</div>

