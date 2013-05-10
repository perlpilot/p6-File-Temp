module Temp:ver<0.01>;

# Characters used to create temporary file/directory names
constant FILECHARS = 'a'..'z', 'A'..'Z', 0..9, '_';
constant MAX-RETRIES = 10;

sub gen-random($n) {
    return join '', map { FILECHARS[Int(rand * +FILECHARS)] }, ^$n;
}

my @open-files;

sub find-tempdir() {
    given $*OS {
        when 'MSWin32' {
            return %*ENV<TEMP> || "C:/Temp";
        }
        default {
            return "/tmp";
        }
    }
}

sub tempfile (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = find-tempdir(),        # where to create these temp files
    :$prefix? = '',             # filename prefix
    :$suffix? = '',             # filename suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {

    my $count = MAX-RETRIES;
    while ($count--) {
        my $tempfile = $template;
        $tempfile ~~ s/ '*' ** 4..* /{ gen-random($/.chars) }/;
        my $filename = IO::Path.new($tempdir).child("$prefix$tempfile$suffix");
        next if $filename ~~ :e;
        my $fh = try { CATCH { next }; open $filename, :w;  };
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
