<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="main.css">
		<script src="jquery.min.js"></script>
	</head>
	<body>
		[% INCLUDE "PostItFunction.tpl" %]
		[% INCLUDE "ajax.tpl" %]
		[% INCLUDE "header.tpl" %]
		[% IF Page == "Login" %]
			[% INCLUDE "login.tpl" %]
		[% END %]

		[% IF Page == "Home" %]
			[% INCLUDE "home.tpl" %]
		[% END %]

		[% IF Page == "Reload" %]
			<script>location.replace("https://phasmo-saboteur.retrotech.one");</script>
		[% END %]

	</body>
</html>
