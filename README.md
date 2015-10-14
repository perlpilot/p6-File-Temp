File::Temp
==========

[![Build Status](https://travis-ci.org/perlpilot/p6-file-temp.svg?branch=master)](https://travis-ci.org/perlpilot/p6-file-temp)

Create temporary files.
This module is loosely based on the Perl 5 module of the same name.

Synopsis
========

    # Generate a temp file in a temp dir
    my ($filename,$filehandle) = tempfile;

    # specify a template for the filename
    #  * are replaced with random characters
    my ($filename,$filehandle) = tempfile("******");

    # Automatically unlink files at end of program (this is the default)
    my ($filename,$filehandle) = tempfile("******", :unlink);

    # Specify the directory where the tempfile will be created
    my ($filename,$filehandle) = tempfile(:tempdir("/path/to/my/dir"));

    # don't unlink this one
    my ($filename,$filehandle) = tempfile(:tempdir('.'), :!unlink);

    # specify a prefix and suffix for the filename
    my ($filename,$filehandle) = tempfile(:prefix('foo'), :suffix(".txt"));







