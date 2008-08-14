
.PHONY=clean

clean:
	perl -MFile::Find -e'find  sub{/(\~|\.bak)$$/ && unlink},"./"'
