unit module File::Temp:ver<0.02>;

use File::Directory::Tree;

# Characters used to create temporary file/directory names
my @filechars = flat('a'..'z', 'A'..'Z', 0..9, '_');
constant MAX-RETRIES = 10;

my @created-files;

sub make-temp($type, $template, $tempdir, $prefix, $suffix, $unlink) {
    my $count = MAX-RETRIES;
    while ($count--) {
        my $tempfile = $template;
        $tempfile ~~ s/ '*' ** 4..* /{ @filechars.roll($/.chars).join }/;
        my $name = $*SPEC.catfile($tempdir,"$prefix$tempfile$suffix");
        next if $name.IO ~~ :e;
        my $fh;
        if $type eq 'file' {
            $fh = try { CATCH { next }; open $name, :rw, :exclusive;  };
        }
        else {
            try { CATCH { next }; mkdir($name) };
        }
        push @created-files, [ $name, $fh ] if $unlink;
        return $type eq 'file' ?? ($name,$fh) !! $name;
    }
    return ();
}


sub tempfile (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = $*TMPDIR,      # where to create these temp files
    :$prefix? = '',             # filename prefix
    :$suffix? = '',             # filename suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {
    return make-temp('file', $template, $tempdir, $prefix, $suffix, $unlink);
}

our sub tempdir (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = $*TMPDIR,      # where to create tempdir
    :$prefix? = '',             # directory prefix
    :$suffix? = '',             # directory suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {
    return make-temp('dir', $template, $tempdir, $prefix, $suffix, $unlink);
}

END {
    for @created-files -> [$fn,$fh] {
        $fh.close if $fh;
        next unless $fn.IO ~~ :e; # maybe warn here

        if $fn.IO ~~ :f
        {
            unlink($fn);
        }
        elsif $fn.IO ~~ :d
        {
            rmtree($fn);
        }
    }
}

