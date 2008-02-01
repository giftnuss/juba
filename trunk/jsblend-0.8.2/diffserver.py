## 
## Author: Nimish Pachapurkar <npac@spikesource.com>
## Basic HTTP server for JSBlend
## (C) 2007, SpikeSource, Inc.
## $Id: diffserver.py 81593 2007-06-30 01:21:36Z npac $
## 

"""
Works as a web server over HTTP and HTTPS for the JSBlend tool.
Implements simple HTTP and HTTPS servers. 
Some code for HTTPS server uses code from:
    http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/442473
"""

import string, cgi, time, sys, socket
import os, os.path
from SocketServer import BaseServer
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
try:
    from OpenSSL import SSL
    openssl = True
except:
    openssl = False

if os.name == "nt":
    tmp_dir = os.path.join("C:\\", "Temp")
elif os.name == "posix":
    tmp_dir = os.path.join("/", "tmp")

mydir = os.curdir
if len(sys.argv) > 0:
    mydir = os.path.abspath(os.path.dirname(sys.argv[0]))
#print "server dir: " + mydir

"""
This exception is triggered when accessing a remote file
generates a password challenge.
"""
class WaitingForInputException(Exception):
    pass

"""
 Generic run command routine that works on linux as well as windows.
 Uses subprocess module.
 Argument is LIST of arguments that make up the command
 eg: runCommand(['ls', '-l', '/tmp'])
 Returns a tuple of return value, output and error
"""
def runCommand(cmd):
    import subprocess
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output = []
    error = []
    for line in proc.stdout:
        if line == "":
            break
        output.append(line)
    proc.stdout.close()
    for line in proc.stderr:
        if line == "":
            break
        error.append(line)
    proc.stderr.close()
    retval = proc.wait()
    print ">>> Return code: " + str(retval)
    return (retval, output, error)

def obfuscatePassword(passwd):
    if passwd == None:
        return str(passwd)
    elif type(passwd) == str:
        if passwd == '':
            return ''
        return '*******'

"""
Runs a remote command over scp or ssh using pexpect module
to interact by getting password from user when challenged.
"""
def runSecureRemoteCommand(cmd, handler=None, passwd=None, which='left'):
    from pexpect import pexpect
    print ">>> Running command: " + ' '.join(cmd)
    print ">>> Password: " + obfuscatePassword(passwd)
    c = pexpect.spawn(' '.join(cmd))
    index = -1
    cnt = 0
    while cnt < 3:
        try:
            print "Waiting ..."
            index = c.expect(['continue connecting.*', '.ssword:*'], timeout=20)
            if index == 0:
                # In case a confirmation is needed
                print "Confirmation ..."
                c.sendline('yes')
            elif index == 1:
                ## Replace this call with an http call
                if passwd == None:
                    i = 0
                    while i < 5:
                        print ">>> Sending fake password."
                        i += 1
                        try:
                            c.sendline(str(passwd))
                            c.expect('.ssword:*', timeout=10)
                        except:
                            print "passwd is none"
                            handler.getPassword(which)
                            raise WaitingForInputException, ""
                else:
                    c.sendline(passwd)
        except:
            if passwd == None and index == 1:
                print "passwd is none"
                handler.getPassword(which)
                raise WaitingForInputException, ""
        cnt += 1
    c.expect(pexpect.EOF)
    if c.status != None and c.status != 0:
        raise Exception, "Could not run remote command : " + ' '.join(cmd)

"""
Returns True if the file is a remote url
Currently only scp:// is supported.
"""
def isRemoteFile(file):
    if file.startswith('scp://'):
        return True
    elif file.startswith('http://') or file.startswith('https://'):
        return True
    return False

"""
Returns true if only readonly mode is supported by the underlying protocol.
"""
def onlyReadOnlySupported(file):
    if file.startswith('http://') or file.startswith('https://'):
        return True
    return False

"""
Gets remote files, generates diffs, and interacts with the 
JSBlend server.
"""
class DiffServer:
    def __init__(self):
        self.diff = None
        self.handler = None
        self.checkDiffCommand()

    def setHandler(self, handler):
        self.handler = handler
        #print "!!! Handler set: " + str(self.handler)

    """
    Find a given executable binary in system PATH
    """
    def findBinary(self, binary="diff"):
        dirs = os.environ.get("PATH", "").split(os.pathsep)
        #print dirs
        for dir in dirs:
            bin = os.path.join(dir, binary)
            if os.path.isfile(bin) and os.access(bin, os.X_OK):
                return bin
        return None

    """
    Check if the diff command exists.
    """
    def checkDiffCommand(self):
        if os.name == "nt":
            self.diff = self.findBinary("diff.exe")
        elif os.name == "posix":
            self.diff = self.findBinary("diff")

        if self.diff == None:
            raise Exception, "!!! GNU diff command not found in system PATH."
        else:
            print ">>> Using diff command from: " + self.diff

    def _getMaxLineLength(self, file):
        if os.path.isfile(file):
            try:
                f = open(file, "r")
                max = 0
                for line in f.readlines():
                    line = line.strip("\n")
                    if len(line) > max:
                        max = len(line)
                f.close()
                return max
            except:
                raise Exception, "!!! Cannot open file for reading: " + file
        return 0

    """
    Split the remote file url into [user@]hostname and filepath
    """
    def getRemoteFileParts(self, file):
        if file.startswith('scp://'):
            filepath = file[6:]
            parts = filepath.split(':')
            if len(parts) < 2:
                raise Exception, "Invalid url format. Must be of the form 'scp://[user@]host:/path'."
            host = ":".join(parts[:-1])
            path = parts[-1]
            return (host, path)
        elif file.startswith('http://') or file.startswith('https://'):
            return ('', file)
        elif file.startswith('file://'):
            return ('', file[7:])
        elif file.find('://') == -1:
            return ('', file)
        else:
            raise Exception, "Unsupported scheme for remote file: " + file

    """ 
    Returns a local file path that corresponds to the remote file url
    """
    def getLocalFileForRemoteFile(self, rfile):
        import hashlib
        if isRemoteFile(rfile):
            (host, path) = self.getRemoteFileParts(rfile)
            filename = os.path.basename(path)
            filename = filename + hashlib.md5(rfile).hexdigest().lower()
            #print "Local file: " + filename
            return os.path.join(tmp_dir, filename)
        elif rfile.startswith('file://'):
            return os.path.abspath(rfile[7:])
        else:
            return rfile

    """
    Saves remote file.
    """
    def saveRemoteFile(self, file, passwd=None):
        if isRemoteFile(file):
            (host, path) = self.getRemoteFileParts(file)
            filename = os.path.basename(path)
            lfile = self.getLocalFileForRemoteFile(file)
            if os.name == "nt":
                ## Windows
                winscp = self.findBinary("WinSCP.com")
                if winscp == None:
                    raise Exception, "Could not find WinSCP.com binary in PATH. It is required for scp support on Windows."
                cmd = [winscp, "/console", "/command", 'option batch on', 'option confirm off', 'open ' + host, 'lcd ' + tmp_dir,
                        'cd ' + os.path.dirname(path), 'put ' + os.path.basename(lfile), 
                        'mv ' + os.path.basename(lfile) + ' ' + filename, 'exit']
                print " ".join(cmd)
                (ret, out, err) = runCommand(cmd)
                if ret != 0:
                    raise Exception, "Command did not run successfully. Error: " + "\n".join(err)
            else:
                scp = self.findBinary('scp')
                if scp == None:
                    raise Exception, "Could not find scp binary in PATH. It is required for scp support."
                try:
                    runSecureRemoteCommand([scp, lfile, host + ':' + path], self.handler, passwd)
                except WaitingForInputException, w:
                    raise w
                except:
                    raise Exception, "Could not save remote file: " + file
        elif file.startswith('file://'):
            return False
        else:
            raise Exception, "Unsupported scheme for remote file: " + file

    """
    Gets copy of a remote file using specified scheme
    """
    def getRemoteFile(self, file, passwd=None, which='left'):
        import hashlib
        if isRemoteFile(file):
            (host, path) = self.getRemoteFileParts(file)
            lfile = self.getLocalFileForRemoteFile(file)
            filename = os.path.basename(lfile)
            #print "Local file: " + filename
            if file.startswith('scp://'):
                if os.name == "nt":
                    ## Windows
                    ## Check for WinSCP.com
                    winscp = self.findBinary("WinSCP.com")
                    if winscp == None:
                        raise Exception, "Could not find WinSCP.com binary. It is required for scp support on Windows."
                    if os.path.exists(lfile):
                        os.remove(lfile)
                    cmd = [winscp, "/console", "/command", 'option batch on', 'option confirm off', 'open ' + host, 
                            'lcd ' + tmp_dir, 'get ' + path, "exit"]
                    print " ".join(cmd)
                    (ret, out, err) = runCommand(cmd)
                    if ret != 0:
                        raise Exception, "Command did not run successfully. " + "\n".join(err)
                    else:
                        (ret, out, err) = runCommand(["move", os.path.join(tmp_dir, os.path.basename(file)), lfile])
                        if ret != 0:
                            raise Exception, "Could not move file successfully. " + "\n".join(err)
                else:
                    scp = self.findBinary('scp')
                    if scp == None:
                        raise Exception, "Could not find scp binary in PATH. It is required for scp support."
                    try:
                        runSecureRemoteCommand([scp, host + ':' + path, lfile], self.handler, passwd, which)
                    except WaitingForInputException, w:
                        raise w
                    except:
                        raise Exception, "Could not fetch remote file: " + file
            elif file.startswith('http://') or file.startswith('https://'):
                from urllib2 import urlopen
                f = urlopen(file)
                w = open(lfile, "w")
                w.write(f.read())
                w.close()
                f.close()
            if os.path.exists(lfile):
                return lfile
            else:
                raise Exception, "Could not save remote file locally: " + lfile
        elif file.startswith('file://'):
            return file[7:]
        else:
            raise Exception, "Unsupported scheme for remote file: " + file

    """
    Delete a given remote file path.
    """
    def deleteRemoteFile(self, file, passwd=None):
        print ">>> Shadow password: " + obfuscatePassword(passwd)
        if isRemoteFile(file):
            (host, path) = self.getRemoteFileParts(file)
            ssh = self.findBinary('ssh')
            if ssh == None:
                raise Exception, "Could not find ssh binary in PATH. It is required for remote file support."
            try:
                runSecureRemoteCommand([ssh, host, 'rm', '-f', path], self.handler, passwd)
            except:
                raise Exception, "Could not delete remote file: " + file

    """
    Moves a file from src to dest on a remote machine
    (Note: Both files must be on the same remote machine)
    """
    def moveRemoteFile(self, src, dest, passwd=None):
        if isRemoteFile(src) and isRemoteFile(dest):
            (shost, spath) = self.getRemoteFileParts(src)
            (dhost, dpath) = self.getRemoteFileParts(dest)
            if shost != dhost:
                raise Exception, "Left and right files on different hosts not supported."
            ssh = self.findBinary('ssh')
            if ssh == None:
                raise Exception, "Could not find ssh binary in PATH. It is required for remote file support."
            try:
                runSecureRemoteCommand([ssh, shost, 'mv', '-f', spath, dpath], self.handler, passwd)
            except:
                raise Exception, "Could not move remote file. \n[src=" + src + ", \ndest=" + dest + "]"

    """
    Gets file diff using diff command
    """
    def getFileDiff(self, fileLeft, fileRight):
        cols = 301;
        try:
            lines = []
        
            if os.path.isabs(fileLeft):
                fileLeft = 'file://' + fileLeft
            if os.path.isabs(fileRight):
                fileRight = 'file://' + fileRight
            fileLeft = self.getRemoteFile(fileLeft)
            fileRight = self.getRemoteFile(fileRight)
            if os.path.isfile(fileLeft) and os.path.isfile(fileRight):
                maxLeft = self._getMaxLineLength(fileLeft)
                maxRight = self._getMaxLineLength(fileRight)
                total = maxLeft + maxRight
                if total >= cols:
                    cols = ((total + 5) % 2 == 0) and (total + 4) or (total + 5)
                cmd = [self.diff, "-y", "--expand-tabs", "--width=" + str(cols), fileLeft, fileRight]
                print ">>> Running command: " + str(cmd)
                ret, output, error = runCommand(cmd)
                cnt = 0
                for line in output:
                    #line = line.strip("\n")
                    #if cnt > 0:
                    #    line = line + "\n"
                    lines.append(line)
                    cnt = cnt + 1
            else:
                print "!!! ERROR: No such file(s) " + fileLeft + ", " + fileRight
                lines = ["ERROR: No such file(s)\n"]
        except Exception, e:
            lines = ["ERROR: " + str(e) + "\n"]
        return (cols, lines)

    def getIntralineDiff(self, line1, line2):
        import difflib
        output = []
        seq = difflib.SequenceMatcher(lambda x: x == " ", line1, line2)
        for (s1, s2, l) in seq.get_matching_blocks():
            print str(s1) + ":" + str(s2) + ":" + str(l)
            output.append(str(s1) + ":" + str(s2) + ":" + str(l) + "\n")
        return output

    def _useSamePasswords(self, file, shadowFile, passwd, shadowPasswd=None):
        if file.startswith('scp://') and shadowFile.startswith('scp://'):
            # Both are remote over scp
            if passwd != None:
                (h1, f1) = self.getRemoteFileParts(file)
                (h2, f2) = self.getRemoteFileParts(shadowFile)
                if h1 == h2:
                    return True
        return False

    """
    Delete the left file (ignore any modifications) and move the right file
    as the left file.
    """
    def useRightFile(self, file, shadowFile, passwd=None, shadowPasswd=None):
        try:
            if file == shadowFile:
                return (False, "ERROR: Left file is same as the Right file.\n")
            lfile = self.getLocalFileForRemoteFile(file)
            lshadowFile = self.getLocalFileForRemoteFile(shadowFile)
            if os.path.isfile(lshadowFile) and os.path.isfile(lfile):
                os.remove(lfile)
                print ">>> Moving " + lshadowFile + " as " + lfile
                os.rename(lshadowFile, lfile)
                if isRemoteFile(file) and not onlyReadOnlySupported(file):
                    self.deleteRemoteFile(file, passwd)
                    if isRemoteFile(shadowFile) and not onlyReadOnlySupported(shadowFile):
                        self.moveRemoteFile(shadowFile, file, shadowPasswd)
                return (True, "")
            return (False, "ERROR: No such file(s).\n")
        except Exception, e:
            return (False, "ERROR: " + str(e))

    def useLeftFile(self, file, shadowFile, passwd=None, shadowPasswd=None):
        try:
            if file == shadowFile:
                return (False, "ERROR: Left file is same as the Right file.\n")
            lfile = self.getLocalFileForRemoteFile(file)
            lshadowFile = self.getLocalFileForRemoteFile(shadowFile)
            if os.path.isfile(lshadowFile) and os.path.isfile(lfile):
                if os.access(lshadowFile, os.R_OK):
                    print ">>> Deleting file: " + lshadowFile
                    os.remove(lshadowFile)
                    if isRemoteFile(shadowFile) and not onlyReadOnlySupported(shadowFile):
                        self.deleteRemoteFile(shadowFile, shadowPasswd)
                    return (True, "")
                else:
                    return (False, "ERROR: File is not writable " + lshadowFile + "\n")
            else:
                return (False, "ERROR: No such file(s).\n")
            return False
        except Exception, e:
            return (False, "ERROR: " + str(e))

    def saveFile(self, file, shadowFile, contents, deleteright="False", passwd=None, shadowPasswd=None):
        try:
            print ">>> Writing contents to " + file
            #print ">>> Contents: " + contents
            lfile = self.getLocalFileForRemoteFile(file)
            lshadowFile = self.getLocalFileForRemoteFile(shadowFile)
    
            if os.access(lfile, os.W_OK):
                f = open(lfile, "w")
                f.write(contents)
                f.close()
            ## In case it is a remote file
            if isRemoteFile(file) and not onlyReadOnlySupported(file):
                self.saveRemoteFile(file, passwd)
            if deleteright.upper() == "TRUE":
                if file == shadowFile:
                    return (False, "ERROR: Left file is same as the Right file. Cannot delete.\n")
                if os.access(lshadowFile, os.W_OK):
                    print ">>> Deleting file " + lshadowFile
                    os.remove(lshadowFile);
                    if isRemoteFile(shadowFile) and not onlyReadOnlySupported(shadowFile):
                        self.deleteRemoteFile(shadowFile, shadowPasswd)
                else:
                    return (False, "ERROR: File is not writable " + lshadowFile + "\n")
            return (True, "")
        except Exception, e:
            return (False, "ERROR: " + str(e))

"""
HTTPRequestHandler class specially for JSBlend requests.
"""
class JSBlendHandler(BaseHTTPRequestHandler):

    def getParamValue(self, param):
        if self.body == None:
            self._readQueryString()

        if self.body.has_key(param):
            if len(self.body[param]) == 1:
                return self.body[param][0]
            else:
                return self.body[param]

    def getSingleValue(self, param, failonerror=True):
        val = self.getParamValue(param)
        if val != None and len(val) != 1:
            return val
        else:
            if failonerror:
                raise Exception, "No single value for parameter: " + param
            return None

    def _readQueryString(self):
        self.body = {}
        if self.path.find('?')>-1:
            pathparts = self.path.split('?',1)
            self.path = pathparts[0]
            qs = pathparts[1]
            self.body = cgi.parse_qs(qs, keep_blank_values=1)
            #print self.body

    def _readFormBody(self, length):
        self.body = {}
        qs = self.rfile.read(length)
        self.body = cgi.parse_qs(qs, keep_blank_values=1)
        #print self.body

    def _handlePasswords(self, diffserve, fileLeft, fileRight):
        leftPasswd = None
        rightPasswd = None
        leftPasswd = self.getSingleValue('leftPassword', False)
        print ">>> Left Password: " + obfuscatePassword(leftPasswd)
        try:
            fileLeft = diffserve.getRemoteFile(fileLeft, leftPasswd, 'left')
        except WaitingForInputException, w:
            return None
        except Exception, e:
            raise e
        rightPasswd = self.getSingleValue('rightPassword', False)
        print ">>> Right Password: " + obfuscatePassword(rightPasswd)
        try:
            fileRight = diffserve.getRemoteFile(fileRight, rightPasswd, 'right')
        except WaitingForInputException, w:
            return None
        except Exception, e:
            raise e

        return (fileLeft, fileRight)

    def getFileDiff(self):
        try:
            fileLeft = self.getSingleValue('left')
            fileRight = self.getSingleValue('right')
            if os.path.isabs(fileLeft):
                fileLeft = 'file://' + fileLeft
            if os.path.isabs(fileRight):
                fileRight = 'file://' + fileRight
            print ">>> Files: ", fileLeft, " \n ", fileRight
            diffserve = DiffServer()
            diffserve.setHandler(self)
            tuple = self._handlePasswords(diffserve, fileLeft, fileRight)
            if tuple == None:
                return
            (fileLeft, fileRight) = tuple
            (cols, output) = diffserve.getFileDiff(fileLeft, fileRight)
            if len(output) > 0 and output[0].startswith('ERROR:'):
                self.wfile.write(output[0])
            else:
                self.wfile.write("COLUMNS:" + str(cols) + "\n")
                for line in output:
                    self.wfile.write(line)
        except Exception, e:
            self.wfile.write('ERROR:' + str(e))

    def getShadowFile(self):
        pass

    def getIntralineDiff(self):
        line1 = self.getSingleValue("leftline")
        line2 = self.getSingleValue("rightline")
        diffserve = DiffServer()
        output = diffserve.getIntralineDiff(line1, line2)
        for line in output:
            self.wfile.write(line)

    def useRightFile(self):
        file = self.getSingleValue("left")
        shadowFile = self.getSingleValue("right")
        passwd = self.getSingleValue('leftPassword', False)
        shadowPasswd = self.getSingleValue('rightPassword', False)
        print ">>> [", obfuscatePassword(passwd), "] [", obfuscatePassword(shadowPasswd), "]"
        diffserve = DiffServer()
        diffserve.setHandler(self)
        (ret, err) = diffserve.useRightFile(file, shadowFile, passwd, shadowPasswd)
        if not ret:
            self.wfile.write(err)
        return ret
       
    def useLeftFile(self):
        file = self.getSingleValue("left")
        shadowFile = self.getSingleValue("right")
        passwd = self.getSingleValue('leftPassword', False)
        shadowPasswd = self.getSingleValue('rightPassword', False)
        print ">>> [", obfuscatePassword(passwd), "] [", obfuscatePassword(shadowPasswd), "]"
        diffserve = DiffServer()
        diffserve.setHandler(self)
        (ret, err) = diffserve.useLeftFile(file, shadowFile, passwd, shadowPasswd)
        if not ret:
            self.wfile.write(err)
        return ret

    def saveFile(self):
        file = self.getSingleValue("left")
        shadowFile = self.getSingleValue("right")
        deleteright = self.getSingleValue("deleteright")
        contents = self.getSingleValue("contents")
        passwd = self.getSingleValue('leftPassword', False)
        shadowPasswd = self.getSingleValue('rightPassword', False)
        print ">>> [", obfuscatePassword(passwd), "] [", obfuscatePassword(shadowPasswd), "]"
        diffserve = DiffServer()
        diffserve.setHandler(self)

        (ret, err) = diffserve.saveFile(file, shadowFile, contents, deleteright, passwd, shadowPasswd)
        if not ret:
            self.wfile.write(err)
        return ret

    def saveBothFiles(self):
        file = self.getSingleValue("left")
        shadowFile = self.getSingleValue("right")
        contentsleft = self.getSingleValue("contentsleft")
        contentsright = self.getSingleValue("contentsright")
        passwd = self.getSingleValue('leftPassword', False)
        shadowPasswd = self.getSingleValue('rightPassword', False)
        print ">>> [", obfuscatePassword(passwd), "] [", obfuscatePassword(shadowPasswd), "]"
        diffserve = DiffServer()
        diffserve.setHandler(self)

        ## Save first file
        print ">>> Saving first file: "
        (ret, err) = diffserve.saveFile(file, shadowFile, contentsleft, "False", passwd, shadowPasswd)
        if not ret:
            self.wfile.write(err)
        else:
            ## The other file
            print ">>> Saving second file: "
            (ret, err) = diffserve.saveFile(shadowFile, file, contentsright, "False", shadowPasswd, passwd)
            if not ret:
                self.wfile.write(err)
        return ret

    def getPassword(self, type):
        print "!!! Getting password: " + type
        if type == "left":
            self.wfile.write('PASSWORDLEFT:')
        else:
            self.wfile.write('PASSWORDRIGHT:')

    def do_GET(self):
        try:
            self._readQueryString()
            if self.path == "/":
                self.path = "/viewdiff.html"
            if self.path.endswith(".esp") or self.path.endswith(".php"):   #our dynamic content
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                
                ## Get the params
                method = self.getParamValue('method')
                print ">>> Method: ", method
                if method == 'getFiles':
                    self.getFileDiff()
                elif method == 'getIntralineDiff':
                    self.getIntralineDiff()
                elif method == 'useRightFile':
                    ret = self.useRightFile()
                elif method == 'useLeftFile':
                    ret = self.useLeftFile()
                print ">>> Returning"
                return
            else:
                self.send_response(200)
                self.path = self.path.lstrip("/")
                filetoserve = os.path.join(mydir, self.path)
                if self.path.endswith(".html"):
                    f = open(filetoserve, "r")
                    self.send_header('Content-type', 'text/html')
                elif self.path.endswith(".js"):
                    f = open(filetoserve, "r")
                    self.send_header("Content-type", "text/javascript")
                else:
                    f = open(filetoserve, "rb")
                self.end_headers()
                self.wfile.write(f.read())
                f.close()
                return
 
            return
        except IOError:
            self.send_error(404,'File Not Found: %s' % self.path)
     

    def do_POST(self):
        try:
            ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
            print ctype
            if ctype == 'application/x-www-form-urlencoded':
                length = int(self.headers.getheader('content-length'))
                self._readFormBody(length)
                method = self.getSingleValue('method')
                ret = False
                if method == 'saveFile':
                    ret = self.saveFile()
                elif method == 'saveFiles':
                    ret = self.saveBothFiles()
                if not ret:
                    raise Exception, ret
                self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write('Done')
            return
        except :
            pass

"""
Implements HTTP over SSL (HTTPS) using a server key file.
"""
class SecureHTTPServer(HTTPServer):
    def __init__(self, server_address, HandlerClass):
        BaseServer.__init__(self, server_address, HandlerClass)
        ctx = SSL.Context(SSL.SSLv23_METHOD)
        ## server.pem's location (containing the server private key and the server certificate).
        ## ./ssl/server.pem
        fpem = os.path.join(os.path.dirname(sys.argv[0]), 'ssl', 'server.pem')
        ctx.use_privatekey_file(fpem)
        ctx.use_certificate_file(fpem)
        self.socket = SSL.Connection(ctx, socket.socket(self.address_family,self.socket_type))
        self.server_bind()
        self.server_activate()

"""
SSL-enabled incarnation of JSBlendHandler
"""
class SecureJSBlendHandler(JSBlendHandler):
    def setup(self):
        self.connection = self.request
        self.rfile = socket._fileobject(self.request, "rb", self.rbufsize)
        self.wfile = socket._fileobject(self.request, "wb", self.wbufsize)

"""
Kill the server
"""
def killServer(server):
    if server:
        server.socket.close()

def main():
    try:
        if openssl:
            port = 8443
            server = SecureHTTPServer(('', port), SecureJSBlendHandler)
            print '>>> Starting secure HTTP server on port ' + str(port) + ' ...'
        else:
            print "!!! OpenSSL support not installed. Please install pyOpenSSL package from 'http://pyopenssl.sourceforge.net/'"
            print "!!! Using non-secure HTTP server mode."
            port = 8888
            server = HTTPServer(('', port), JSBlendHandler)
            print ">>> Starting non-secure HTTP server on port " + str(port) + " ..."
        server.serve_forever()
    except KeyboardInterrupt:
        print '!!! ^C received, shutting down server'
        killServer(server)

if __name__ == '__main__':
    main()

