#!/usr/bin/env python
## 
## Author: Nimish Pachapurkar <npac@spikesource.com>
## Command line invoker for jsblend tool
## (C) 2007, SpikeSource, Inc.
## $Id: jsblend.py 28 2007-10-03 21:27:32Z npac $
## 

import optparse, sys
import os, os.path
import urllib
from diffserver import runCommand, isRemoteFile, onlyReadOnlySupported, tmp_dir, killServer

daemon = None
output = None
thisdir = os.curdir
if len(sys.argv) > 0:
    thisdir = os.path.abspath(os.path.dirname(sys.argv[0]))
#print "DIR: " + thisdir
p = None

try:
    from OpenSSL import SSL
    default_server = "https://localhost:8443"
except:
    default_server = "http://localhost:8888"

def help():
    ## TODO: Unify help messages
    print "Usage: " + sys.argv[0] + " <left-file> <right-file> [options]"
    print "One or both files can be remote."
    print "Supported schemes for remote files are: "
    print "      scp            (scp://user@host:/path/to/file)"
    print "      http or https  (http://exmaple.com/file/url)"
    print 
    if p:
        #p.print_help()
        print p.format_option_help()
    print

if __name__ == "__main__":
    try:
        p = optparse.OptionParser()
        p.add_option("-b", "--browser",
            action="store",
            type="string",
            nargs=1,
            dest="browser",
            default=None,
            help="Specify path to a web browser executable file.")
        p.add_option("-s", "--server",
            action="store",
            type="string",
            nargs=1,
            dest="server",
            default=default_server,
            help="Specify the protocol, host and port of the local server. (Default '" + default_server + "')")
        p.add_option("-r", "--readonly",
            action="store_true",
            dest="readonly",
            default=False,
            help="Show diff in readonly mode.")

        #print sys.argv
        if len(sys.argv) < 3:
            if len(sys.argv) > 1 and ( sys.argv[1] == "-h" or sys.argv[1] == "--help" ):
                help()
                sys.exit(1)
            else:
                print "!!! ERROR: Must specify at least two file paths."
                help()
                sys.exit(1)
        else:
            leftFile = sys.argv[1]
            rightFile = sys.argv[2]
            if not os.path.isabs(leftFile) and not isRemoteFile(leftFile):
                leftFile = os.path.abspath(leftFile)
            if not os.path.isabs(rightFile) and not isRemoteFile(rightFile):
                rightFile = os.path.abspath(rightFile)
            sys.argv.pop(1)
            sys.argv.pop(1)

        opt, args = p.parse_args()

        ## Check if the server is running
        import urllib2
        try:
            conn = urllib2.urlopen(opt.server)
            conn.close()
        except Exception, e:
            print "!!! Server not running at " + opt.server
            if opt.server == default_server:
                output = file(os.path.join(thisdir, "output.log"), "a")
                import subprocess
                cmd = ['python', os.path.join(thisdir, 'diffserver.py')]
                #print " ".join(cmd)
                daemon = subprocess.Popen(cmd, stdout=output, stderr=output)
            else:
                print "!!! ERROR: Please start the service using 'python diffserver.py'"
                raise e

        #print str(opt.browser)
        if opt.browser:
            if not os.path.exists(opt.browser) or not os.access(opt.browser, os.X_OK):
                print "!!! ERROR: No such file or file not executable: " + opt.browser
                sys.exit(1)
        else:
            print ">>> No browser specified. Will attempt to use firefox. Make sure firefox is in your path."
            opt.browser = "firefox"

        if (onlyReadOnlySupported(leftFile) or onlyReadOnlySupported(rightFile)) and not opt.readonly:
            print ">>> One or both of your remote files cannot be written back. The files will only saved locally in " + tmp_dir + "."

        url = opt.server + "/viewdiff.html?" + urllib.urlencode({'left' :leftFile, 'right': rightFile, 'readonly': str(opt.readonly).lower()})
        cmd = [opt.browser, url]
        (ret, out, err) = runCommand(cmd)
        if ret != 0:
            print "!!! ERROR: Command failed to run: " + " ".join(cmd)
            print "!!! Command returned: " + str(err)

    except KeyboardInterrupt:
        if output:
            output.close()
        killServer(daemon)
    except Exception, e:
        print "!!! ERROR: " + str(e)

