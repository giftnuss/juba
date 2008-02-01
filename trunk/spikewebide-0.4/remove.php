<?php
/* The following code block will remove an enabled tool from
   driver.html by neglecting its line when rewriting the file.
   It also removes the output folder corresponding to the 
   tool. The removal of the conf file itself is commented out 
   at the moment. */
require_once 'idelib.php';

$remove = $_GET['tool'];

$driver = file("driver.html");
$fh = fopen("driver.html", 'w');
foreach ($driver as $line) {
    //skip line corresponding to tool to be removed
    if (strpos($line, "<option value=\"" . $remove . "\">") !== false) {
        continue;
    }    
    fwrite($fh, $line);
}
fclose($fh);

//remove file
//unlink("conf/" . $remove);

//remove output directory
//location found through conf file
$path = getOutdir($remove);
if (file_exists($path)) {
    if (is_file($path)) {
        $path = dirname($path);
    }
    wipedir($path, true);
}

//return to the driver page after the removal
echo file_get_contents("driver.html");
?>
