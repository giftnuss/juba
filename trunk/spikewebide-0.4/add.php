<?php
/* This code will parse the driver.html file to determine whether
   to insert the provided tool. Note that regardless of the php 
   outcome, the following html page will always be outputted.*/
require_once 'idelib.php';

$tool = $_GET['tool'];

if (isset($tool)) {
    echo "<FONT SIZE='2'>\n";                       //for relaying feedback
    $path = "conf/" . $tool;
    if (!file_exists($path)) {
        echo $path . " does not exist.<BR>\n";
    } else { 
        $conf = file($path);
        // the display name associated with a conf file is its identity
        $display = grabvalue(find($conf, "plugin.display.name"));

        $driver = file("driver.html");
        $fh = fopen("driver.html", 'w');
        $inside = false;                            //flags whether inside <select> tags
        $found = false;                             //flags whether tool already exists
        foreach ($driver as $line) {
            if ((!$inside) && (strpos($line, "<select name=\"tools\"") !== false)) {
                $inside = true;
            }
            if (($inside) && (strpos($line, ">" . $display . "<") !== false)) {
                $found = true;
            }
            /* When the <select> block has passed, if the tool was never found, it may
               now be inputted. If it was found, the tool will not be entered the second
               time. Both conditions will return some feedback. */
            if (($inside) && (strpos($line, "</select>") !== false)) {
                $inside = false;
                if (!$found) {
                    fwrite($fh, "<option value=\"" . $tool . "\">" . $display . "</option>\n");
                    echo "Added: " . $display . "<BR>\n";
                } else {
                    echo "Already enabled.<BR>\n";
                }
            }
            fwrite($fh, $line);
        }
        fclose($fh);
    }
    echo "</FONT>\n";
} 

?>

<HTML>
<HEAD>
<link href="ide.css" rel="stylesheet" type="text/css"/><style type="text/css">
</HEAD>
<BODY>
<CENTER>

Filename of new Plugin Configuration File<BR><BR>

<FORM NAME='ADD' METHOD='GET' ACTION='add.php'>
.../conf/
<INPUT TYPE='TEXT' NAME='tool'>
<INPUT TYPE='SUBMIT' NAME='SUBMIT' VALUE='Submit'>
</FORM>

<A HREF='driver.html'>Home</A>

</FONT>
</CENTER>
</BODY>
</HTML>
