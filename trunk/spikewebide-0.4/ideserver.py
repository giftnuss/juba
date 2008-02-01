## This python script runs a lightweight server to manage requests
## from the Spike Web IDE. Whenever static components are requested,
## such as HTML, javascript, css, or images, they are simply 
## dispensed. However, as the IDE was originally written in PHP, when
## the browser requests a PHP file, the server passes execution to
## a function that is basically a port of the original PHP functionality.

import string, cgi, os
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from idelib import *

class IDEHandler(BaseHTTPRequestHandler):
    tool = None
    def _getTool(self):
        self.tool = self.getParamValue("tool")

    def getParamValue(self, param):
        if self.body == None:
            self._readQueryString()

        if self.body.has_key(param):
            if len(self.body[param]) == 1:
                return self.body[param][0]
            else:
                return self.body[param]

    def _readQueryString(self):
        self.body = {}
        if self.path.find('?')>-1:
            pathparts = self.path.split('?',1)
            self.path = pathparts[0]
            qs = pathparts[1]
            self.body = cgi.parse_qs(qs, keep_blank_values=1)

    def _readFormBody(self, length):
        self.body = {}
        qs = self.rfile.read(length)
        self.body = cgi.parse_qs(qs, keep_blank_values=1)
  
    # execution from generated forms are only use of POST, so far
    def do_POST(self):
        try:
            ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
            print "POST:" + ctype
            if ctype == 'application/x-www-form-urlencoded': 
                # grab POST data, then GET data
                length = int(self.headers.getheader('content-length'))
                self._readFormBody(length)
                form = self.body
                self._readQueryString()
                self._exec(form)
            else: 
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write('Cannot process this POST request')
        except :
            pass

    def do_GET(self):
        self._readQueryString()
        self.send_response(200)
        if (self.path.endswith(".php")):
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            if self.path == "/add.php":
                self._add()
            elif self.path == "/remove.php":
                self._remove()
            elif self.path == "/load.php":
                self._load()
            elif self.path == "/exec.php":
                self._exec()
            elif self.path == "/execall.php":
                self._execall()
            else:
                self.wfile.write("Can't process this .php file")
        else:
            try:
                filepath = os.curdir + self.path
                if os.path.isdir(filepath):
                    if not filepath.endswith("/"):
                        filepath = filepath + "/"
                    filepath = filepath + "index.html"

                # replace all '/' with os.sep?

                if not os.path.exists(filepath):
                    self.send_error(404, 'File Not Found: %s' % self.path)
                    return
   
                if filepath.endswith(".html"):
                    self.send_header('Content-type', 'text/html')
                elif filepath.endswith(".js"):
                    self.send_header("Content-type", "text/javascript")
                elif filepath.endswith(".css"):
                    self.send_header("Content-type", "text/css")
                elif filepath.endswith(".txt"):
                    self.send_header("Content-type", "text/plain")
                else:
                    self.send_header("Content-type", "application/octet-stream")
 
                self.end_headers()
                f = open(filepath, "r")
                self.wfile.write(f.read())
                f.close()
            except IOError, e:
                self.send_error(404, 'IOError')
                return

    def _add(self):
        self._getTool()
        
        if self.tool:
            self.wfile.write("<FONT SIZE='2'>\n")
            filename = getFilePath(self.tool)
            try:
                file = open(filename, 'r')
                conf = file.readlines()
                display = grabvalue(conf[search(conf, "plugin.display.name")])
             
                input = open('driver.html', 'r')
                driver = input.readlines()
                input.close()
                output = open('driver.html', 'w')
                inside = False
                found = False
            
                for line in driver:
                    if not inside and line.find("<select name=\"tools\"") != -1:
                        inside = True
                    if inside and line.find(">" + display + "<") != -1:
                        found = True
                    if inside and line.find("</select>") != -1:
                        inside = False
                        if not found:
                            output.write("<option value=\"" + self.tool + "\">" + display + "</option>\n")
                            self.wfile.write("Added: " + display + "<BR>\n")
                        else:
                            self.wfile.write("Already enabled.<BR>\n")
                    output.write(line)
                output.close()
            except IOError, e:
                self.wfile.write(filename + " does not exist.<BR>\n")
            self.wfile.write("</FONT>\n")
        self.wfile.write("<HTML>\n")
        self.wfile.write("<HEAD>\n")
        self.wfile.write("<link href=\"ide.css\" rel=\"stylesheet\" type=\"text/css\"/><style type=\"text/css\">\n")
        self.wfile.write("</HEAD>\n")
        self.wfile.write("<BODY>\n")
        self.wfile.write("<CENTER>\n")
        self.wfile.write("Filename of new Plugin Configuration File<BR><BR>\n")
        self.wfile.write("<FORM NAME='ADD' METHOD='GET' ACTION='add.php'>\n")
        self.wfile.write(".../conf/\n")
        self.wfile.write("<INPUT TYPE='TEXT' NAME='tool'>\n")
        self.wfile.write("<INPUT TYPE='SUBMIT' NAME='SUBMIT' VALUE='Submit'>\n")
        self.wfile.write("</FORM>\n")
        self.wfile.write("<A HREF='driver.html'>Home</A>\n")
        self.wfile.write("</FONT>\n")
        self.wfile.write("</CENTER>\n")
        self.wfile.write("</BODY>\n")
        self.wfile.write("</HTML>\n")

    def _remove(self):
        self._getTool()
        input = open('driver.html', 'r')
        driver = input.readlines()
        input.close()
        output = open('driver.html', 'w')
        for line in driver:
            if line.find("<option value=\"" + self.tool + "\">") != -1:
                continue
            output.write(line)
        output.close()

        # remove file?
        # unlink(getFilePath(self.tool))

        # remove output directory
        # output dir found through conf file
        filepath = getOutdir(self.tool)
        if os.path.exists(filepath):
            if os.path.isfile(filepath):
                filepath = os.path.dirname(filepath)
            wipeDir(filepath, True)

        input = open('driver.html', 'r')
        self.wfile.write(input.read())
        input.close()
  
    def _load(self):
        self._getTool()
        if self.tool:
            self.wfile.write(loadTool(self.tool))
            self.wfile.write(refresh(self.tool))
  
    def _exec(self, form):
        self._getTool()
        if self.tool:
            logger = Logger()
            execTool(self.tool, logger, form)
            logger.stop()
        self._load()

    def _execall(self):
        input = open('driver.html', 'r')
        driver = input.readlines()
        input.close()
        inside = False
        logger = Logger()
        for line in driver:
            if not inside:
                if line.find("<select name=\"tools\"") != -1:
                    inside = True
            else:
                if line.find("</select>") != -1:
                    break
                tool = grabvalue(line, "\"")
                execTool(tool, logger)
        logger.stop()

        input = open('driver.html', 'r')
        self.wfile.write(input.read())        
        input.close()

def main():
    try:
        port = 8887
        server = HTTPServer(('', port), IDEHandler)
        print '>>> Started httpserver on port ' + str(port) + ' ...'
        server.serve_forever()
    except KeyboardInterrupt:
        print '!!! ^C received, shutting down server'
        server.socket.close()

if __name__ == '__main__':
    main()
