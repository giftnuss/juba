<?php
/* This code block will seek out all the tools enabled, from parsing
   the driver.html file. It will then call the execTool function 
   with the tool parameter for the actual background execution. */
require_once 'idelib.php';

$driver = file("driver.html");
$inside = false;
$logger = new Logger();
foreach ($driver as $line) {
    // if not inside <select> block, don't bother searching for tools
    if (!$inside) {        
        if (strpos($line, "<select name=\"tools\"") !== false) {
            $inside = true;
            continue;
        }
    // otherwise, grab the string within the quotes and pass it on
    } else {
        if (strpos($line, "</select>") !== false) {
            break;
        }
        $tool = grabvalue($line, "\""); 
        execTool($tool, $logger);
    }
}
$logger->stop();

echo file_get_contents("driver.html");          //return to the driver page
?>
