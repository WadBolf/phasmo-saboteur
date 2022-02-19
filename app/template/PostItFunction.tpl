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
</script>
