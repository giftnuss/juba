#!/usr/bin/env python

## 
## Author: Nimish Pachapurkar <npac@spikesource.com>
## Command-line python tool get intraline diffs
## (C) 2007, SpikeSource, Inc.
## $Id: get_line_diff.py 81593 2007-06-30 01:21:36Z npac $
## 

import sys
from difflib import *

if __name__ == "__main__":
    line1 = sys.argv[1]
    line2 = sys.argv[2]
    f = open("/tmp/z", "w");
    f.write(line1 + "\n" + line2 + "\n");
    f.close();

    seq = SequenceMatcher(lambda x: x == " ", line1, line2)
    for (s1, s2, l) in seq.get_matching_blocks():
        print str(s1) + ":" + str(s2) + ":" + str(l)
