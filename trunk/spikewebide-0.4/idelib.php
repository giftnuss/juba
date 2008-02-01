<?php
/* The following class is meant to write execution IO to 
   a predetermined file. At the moment, it writes basic text
   into an html file, which will later be displayed from 
   within the IDE. */
class Logger
{
    var $fh;
    public function __construct()
    {
        $this->fh = fopen("execlog.html", 'w');
        $this->write("<HTML>\n");
        $this->write("<BODY>\n");
        $this->write("<FONT SIZE='2'>\n");
        $this->write("<PRE>\n");
    }
    public function write($text)
    {
        fwrite($this->fh, $text);
    }
    public function stop()
    {
        $this->write("</PRE>\n");
        $this->write("</FONT>\n");
        $this->write("</BODY>\n");
        $this->write("</HTML>\n");
        fclose($this->fh);
    }
}

/** This function does the background execution, which is the main purpose
  * of the IDE ultimately. It takes the tool name and a reference to a 
  * Logger object(hopefully) to assemble a command line string to execute. 
  *
  * @param $tool name of conf file to execute
  * @param $logger Logger object that will manipulate command line IO
  * @return nothing 
  */ 
function execTool($tool, &$logger)
{
    $conf = file("conf/" . $tool);
    $linenum = 0;      //keep code from looking at same lines again

    //determine the core application command
    $temp = find($conf, "execution.value", $linenum);
    $app = grabvalue($temp);
    $sorter = array(); //will maintain string lines that follow core

    /* For each option listed in the conf file, grab the ideal
       position in the command line string, the option string, 
       and the corresponding value. The value may be pulled from 
       POST information if the method had been requested through
       the generated form */
    while ($temp = find($conf, "option", $linenum)) {
        $var = grabparam($temp);
        $temp = find($conf, $var . "." . "cliexec", $linenum);
        $cliexec = grabvalue($temp);
        $temp = find($conf, $var . "." . "cliorder", $linenum);
        $cliorder = grabvalue($temp);

        $value = $_POST[$var];
        //if had not been invoked by form of load.php
        if (!isset($value)) {
            $temp = find($conf, $var . "." . "value", $linenum);
            $value = grabvalue($temp);
        }

        // add the string to our array
        $sorter[$cliorder] = $cliexec . $value;
    }

    /* The sorter array needs to be sorted to get the command line 
       options in their desired order. After that, the array will 
       be expanded into a string with spaces in between and added
       to the core command. */
    ksort($sorter);                      
    $cmd = $app . implode(" ", $sorter);  

    /* The execlog.html will be written to by means of the logger.
       Note that the actual execution of the command is through 
       the backtick operater on the last logger operation. This 
       way the command is executed and its feedback gets written. */
    $logger->write("++++++++++" . $tool . "++++++++++<BR>\n");
    $logger->write("-----INPUT-----<BR>\n");
    $logger->write($cmd . "<BR>\n");
    $logger->write("-----OUTPUT-----<BR>\n");
    $logger->write(`$cmd` . "<BR><BR>\n");
}

/** This function loads a tool from a conf file. It generates form data
  * based on the options listed inside a conf file. Thus, it simply
  * iterates the file for display options and grabs corresponding values
  * for output. At the moment, it's a very basic output with text and 
  * textboxes. It would not be too difficult to also enable color and style
  * information within conf files to be parsed and displayed here.
  *
  * @param $tool name of conf file to execute
  * @return nothing
  */
function loadTool($tool)
{
    $conf = file("conf/" . $tool);
    $linenum = 0;      //keep code from looking at same lines again

    echo "<HTML>\n<HEAD>\n<style>\n";
    if ($temp = find($conf, "plugin.display.css")) {
        $css = grabvalue($temp);
        echo $css;
    }
    echo "\n</style>\n</head>\n<BODY>\n";
    echo "<BR>";
    echo "<CENTER>\n";
    echo "<FORM NAME='EXEC' METHOD='POST' ACTION='exec.php?tool=" . $tool . "'>\n";
    echo "<INPUT CLASS='button' TYPE='SUBMIT' NAME='SUBMIT' VALUE='Execute'>";
    echo "</CENTER>\n";
    echo "<PRE>\n";
    echo "<TABLE width=\"100%\">\n";
    //foreach display tag present in file
    while ($temp = find($conf, ".display=", $linenum)) {
        $display = grabvalue($temp);
        $var = grabparam($temp);
        $temp = find($conf, $var . "." . "value", $linenum);
        $value = grabvalue($temp);
        echo "<TR><TD align=\"left\"><P>" . $display . ":</P></TD></TR>\n";
        echo "<TR><TD align=\"right\"><INPUT CLASS='text' SIZE='40' NAME='" . $var . "' TYPE='TEXT' VALUE='" . $value . "'></TD></TR>\n";
    }
    echo "</TABLE>\n";
    echo "</PRE>\n</FORM>\n</BODY>\n</HTML>\n";
}

/** This function returns the path to a specific's tool's output
  * directory. This is used by the refresh function to know where
  * to direct the IDE main frame to look for output.
  *
  * @param $tool name of conf file to execute
  * @return string - path to tool's output
  */
function getOutdir($tool)
{
    $conf = file("conf/" . $tool);
    $dir = grabvalue(find($conf, "plugin.outdir"));
    return $dir;
}

/** This function returns the line corresponding to given text.
  * It expects the given line array to correspond to a conf file, 
  * as it disregards any line commented out with a #. Also,
  * note the $start passed by reference. This is for clients 
  * to keep the function from searching through text multiple times.
  * 
  * @param $lines line array of file(should be conf file)
  * @param $text desired text to be found
  * @param $start array index to begin with(defaults to 0)
  * @return string - line on which text was found
  */
function find(&$lines, $text, &$start=0)
{
    for($i=$start; $i<count($lines); $i++) {
        if ($lines[$i]{0} == "#") {
            continue;
        }
        if (strpos($lines[$i], $text) !== false) {
            $start = $i + 1;
            return $lines[$i];
        }
    }
    return false;
}

/** This function is meant to pull the core variable from a line
  * that has been extracted from a conf file. For example, with
  * execution.value='php run.php', the desired result is to
  * grab 'execution', so that clients may seek corresponding variables
  * 
  * @param $line line on which to operate
  * @return string - extracted core variable
  */
function grabparam($line)
{
    return substr($line, 0, strpos($line, "."));
}

/** This function is meant to pull the value from a line that 
  * has been extracted from a conf file. For example, with 
  * execution.value='php run.php', the desired result is to
  * grab 'php run.php', so that it may be executed, concatenated, etc.
  *
  * It is also used in add.php, although that code uses grabvalue
  * with $sep = "\"". This is because add.php parses driver.html seeking
  * the text enclosed in quotes not apostrophes. 
  *
  * @param $line line on which to operate
  * @param $sep separators that define where to extract text
  * @return string - extracted text
  */
function grabvalue($line, $sep="'")
{
    $a = strpos($line, $sep);                  //first instance of $sep
    $b = strrpos($line, $sep);                 //last instance of $sep
    return substr($line, $a + 1, $b - $a - 1);
}

/** This function refreshes the main page of the IDE browser. It 
  * uses getOutdir to know where to search for output.
  *
  * @param $tool name of conf file with directory info
  * @return nothing
  */
function refresh($tool)
{
    $dir = getOutdir($tool);

    echo "<SCRIPT LANGUAGE='javascript'>\n";
    echo "parent.MAIN.location.href = '" . $dir  . "';\n";
    echo "</SCRIPT>\n";
}

/** This function removes the contents of a directory, and the 
  * directory itself if desired. It recursively reads contents
  * and wipes subdirectories before removing those.
  * 
  * @param $dir path of directory to remove
  * @param $itself flag whether to remove directory itself
  * @return nothing
  */
function wipeDir($dir, $itself=false)
{
    // delete contents of directory, before deciding whether to
    // delete the directory itself
    if ($root = @opendir($dir)) {
        while ($file = readdir($root)) {
            if ($file == "."  || $file == "..") {
                continue;
            }
            $fullPath = $dir . "/" . $file;
            // if dir, delete dir contents and dir itself
            // if file, delete the file
            if (is_dir($fullPath)) {
               wipeDir($fullPath, true);
            } else {
               unlink($fullPath);
            }
        }
        // once contents have been wiped, if $itself, remove dir also
        if ($itself) {
            rmdir($dir);
        }
        return 1;
    }
    return 0;
}
?>
