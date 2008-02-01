<?php
/* The following code block relays information to the loadTool
   function and the refresh function. The loadTool will generate
   the form based on the conf file information, and the refresh
   will tell the main frame where to look for output. */
require_once 'idelib.php';

$tool = $_GET['tool'];
if (isset($tool)) {
    if (isValid($tool)) {
        loadTool($tool);
        refresh($tool);
    }
}

/* This function is meant to prevent load calls when there
   are no tools in driver.html to load. Is it necessary?*/
function isValid($tool)
{
    $flag = true;
    if ($tool == '') {
        $flag = false;
    }
    return $flag;
}
?>
