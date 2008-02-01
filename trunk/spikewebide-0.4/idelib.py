# These functions are essentially a port of idelib.php.
# They are almost exactly identical, where possible.

import string, os

# -----------------------------------------------------
# ----------------Conf File Parsing--------------------
# -----------------------------------------------------
def getOutdir(tool):
    input = open(getFilePath(tool))
    conf = input.readlines()
    linenum = search(conf, "plugin.outdir")
    return grabvalue(conf[linenum])

def search(lines, text, start = 0):
    i = start
    while i < len(lines):
        if lines[i][0] != "#":
            if lines[i].find(text) != -1:
                return i
        i = i + 1
    return -1

def grabparam(line):
    return line[0 : line.find(".")]

def grabvalue(line, sep="'"):
    a = line.find(sep)
    b = line.rfind(sep)
    return line[a + 1 : b]

# -----------------------------------------------------
# ------------------IDE Outputting---------------------
# -----------------------------------------------------
def refresh(tool):
    dir = getOutdir(tool)

    output = "<SCRIPT LANGUAGE='javascript'>\n" + \
             "parent.MAIN.location.href = '" + dir + "';\n" + \
             "</SCRIPT>"
    return output

# -----------------------------------------------------
# ----------------Execution Logging--------------------
# -----------------------------------------------------
class Logger:
    output = None
    def __init__(self):
        self.output = open('execlog.html', 'w')
        self.output.write("<HTML>\n")
        self.output.write("<BODY>\n")
        self.output.write("<FONT SIZE='2'>\n")
        self.output.write("<PRE>\n")
    def write(self, text):
        self.output.write(text)
    def stop(self):
        self.output.write("</PRE>\n")
        self.output.write("</FONT>\n")
        self.output.write("</BODY>\n")
        self.output.write("</HTML>\n")
        self.output.close()

# -----------------------------------------------------
# --------------Background Execution-------------------
# -----------------------------------------------------
def execTool(tool, logger, form=None):
    file = open(getFilePath(tool), 'r')
    conf = file.readlines()
    linenum = -1

    linenum = search(conf, "execution.value")
    app = grabvalue(conf[linenum])
    sorter = {}
   
    while 1:
        linenum = search(conf, "option", linenum + 1)
        if linenum == -1:
            break

        var = grabparam(conf[linenum])
        linenum = search(conf, var + "." + "cliexec", linenum + 1)
        cliexec = grabvalue(conf[linenum])
        linenum = search(conf, var + "." + "cliorder", linenum + 1)
        cliorder = grabvalue(conf[linenum])

        if form and form.has_key(var):
            value = form[var][0]
        else:
            linenum = search(conf, var + "." + "value", linenum + 1)
            value = grabvalue(conf[linenum])

        sorter[cliorder] = cliexec + value;

    keys = sorter.keys()
    keys.sort()
    cmd = app
    for key in keys:
        cmd = cmd + sorter[key] + " "

    print cmd
    out = os.popen(cmd)
    feedback = out.read()
    out.close()
    #print feedback

    logger.write("++++++++++" + tool + "++++++++++<BR>\n")
    logger.write("-----INPUT-----<BR>\n")
    logger.write(cmd + "<BR>\n")
    logger.write("-----OUTPUT-----<BR>\n")
    logger.write(feedback + "<BR><BR>\n")

# -----------------------------------------------------
# ------------------Form Generation--------------------
# -----------------------------------------------------

def loadTool(tool):
    file = open(getFilePath(tool), 'r')
    conf = file.readlines()
    file.close()
    linenum = -1

    output = "<HTML>\n<HEAD>\n<style>\n"
    
    temp = search(conf, "plugin.display.css")
    if (temp != -1):
        css = grabvalue(conf[temp])
        output = output + css

    output = output + "\n</style>\n</HEAD>\n<BODY>\n<BR>\n<CENTER>\n" + \
             "<FORM NAME='EXEC' METHOD='POST' ACTION='exec.php?tool=" + tool + "'>\n" + \
             "<INPUT CLASS='button' TYPE='SUBMIT' NAME='SUBMIT' VALUE='Execute'>" + \
             "</CENTER>\n<PRE>\n"

    output = output + "<TABLE width=\"100%\">\n"
    while 1:
        linenum = search(conf, ".display=", linenum + 1)
        if linenum == -1:
            break
        
        display = grabvalue(conf[linenum])
        var = grabparam(conf[linenum])
        linenum = search(conf, var + "." + "value", linenum + 1)
        value = grabvalue(conf[linenum])
        
        output = output + "<TR><TD align=\"left\"><P>" + display + ":</P></TD></TR>\n"
        output = output + "<TR><TD align=\"right\"><INPUT CLASS='text' SIZE='40' NAME='" + var + "' TYPE='TEXT' VALUE='" + value + "'></TD></TR>\n"
    output = output + "</TABLE></PRE>\n</FORM>\n</BODY>\n</HTML>\n"
    return output

# -----------------------------------------------------
# --------------------System Calls---------------------
# -----------------------------------------------------
def getFilePath(tool):
    return "conf" + os.sep + tool

def wipeDir(dir, itself=False):
    if os.path.exists(dir) and os.path.isdir(dir):
        files = os.listdir(dir)
        for file in files:
            fullPath = dir + "/" + file
            if os.path.isdir(fullPath):
               wipeDir(fullPath, True);
            else:
                os.unlink(fullPath);
        if itself:
            os.rmdir(dir)
        return 1
    return 0
