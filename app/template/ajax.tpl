<script>
	// AJAX funcition to get data via ajax.cgi.
        function get_data(mode,  sendData)
        {
                var allData = {
                        "Data": sendData
                };
		
                var jsonString = JSON.stringify(allData);

		var formData = {
			Mode:mode,
			getdata:jsonString,
		};

                $.ajax({
                        "url": "ajax.cgi",
                        "type": "POST",
                        "data": formData,
                        success: function(dataJSON)
                        {
				var data = JSON.parse(dataJSON);
				if ( data["is_error"] !=1 )
				{
					ajaxReturn(data["response"]);
				}
				else
				{
					if (data["response"]["logoff"] == 1)
					{
						postIt({ "Mode": "LOGOUT" }); 
					}
					else
					{
						console.log("AJAX Error: 101");
					}
				}

                        },
			error: function (jqXHR, textStatus, errorThrown)
                       	{
                                // AJAX errored, show a crude JavaScript
                                // error alert, I'll clean this up one day!
				console.log("AJAX Error: 102");
                        }
                })
        }
</script>
