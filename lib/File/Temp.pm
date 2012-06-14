module Temp;

our $VERSION = '0.01';

# Characters used to create temporary file/directory names
constant FILECHARS = 'a'..'z', 'A'..'Z', 0..9, '_';
constant MAX-RETRIES = 1000;

sub gen-random($n) {
    return join '', map { FILECHARS[Int(rand * +FILECHARS)] }, ^$n;
}

my @open-files;

sub tempfile (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = "/tmp",        # where to create these temp files
    :$prefix? = '',             # filename prefix
    :$suffix? = '',             # filename suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {

    for ^MAX-RETRIES {
        my $tempfile = $template;
        $tempfile ~~ s/'*' ** 4..*/{gen-random(~$/.chars)}/;
        my $filename = "$tempdir/$prefix$tempfile$suffix";
        next if $filename.IO ~~ :e;
        my $fh = open $filename, :w or next;
        push @open-files, $filename if $unlink;
        return $filename,$fh;
    }
    return ();
}

END {
    for @open-files -> $f {
        unlink($f);
    }
}

