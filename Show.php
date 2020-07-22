<?php
exec("C:\Progra~1\R\R-3.6.2\bin\Rscript.exe C:\xampp\htdocs\PA\Sep2.R");

$file = fopen("final_output.txt","r");
$the_big_array=fgets($file);

$f=0;
if($the_big_array==0)
{print("<h1>You wont have sepsis . The output is 0.</h1>");
$f=0;
}
else{
	print("<h1>You will have sepsis . The output is 1.</h1>");
$f=1;
}
?>
<html>
<head> <title>Result</title>
</head>
<body>
	<img src="<?php if($f==1)print("Yes.png"); else print("No.png"); ?>">
</body>
</html>