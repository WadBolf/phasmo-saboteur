<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="main.css">
		<script src="jquery.min.js"></script>
	</head>
	<body>
		[% INCLUDE "header.tpl" %]
		[% IF Page == "Login" %]
			[% INCLUDE "login.tpl" %]
		[% END %]

		[% IF Page == "Home" %]
			[% INCLUDE "home.tpl" %]
		[% END %]
	</body>
</html>
