<?php
/* The following code block executes the one tool supplied by
   the GET method. It then includes 'load.php' to return to 
   the dynamic form which will be regenerated. */
require_once 'idelib.php';

$tool = $_GET['tool'];
if (isset($tool)) {
    $logger = new Logger();
    execTool($tool, $logger);
    $logger->stop();

    //refresh the form for further execution - indirect refresh on output also
    include 'load.php';
}    
?>
