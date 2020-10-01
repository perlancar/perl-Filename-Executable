package Filename::Executable;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(check_executable_filename);

our %TYPES = (
    'perl script'   => [qw/.pl/],
    'php script'    => [qw/.php/],
    'python script' => [qw/.py/],
    'ruby script'   => [qw/.rb/],
    'shell script'  => [qw/.sh .bash/],
    'shell archive' => [qw/.shar/],
    'dos program'   => [qw/.exe .com .bat/],
    'appimage'      => [qw/.appimage/],
);
our %EXTS = map { my $type = $_; map {($_=> $type)} @{ $TYPES{$type} } } keys %TYPES;
our $RE_STR  = join("|", sort {length($b) <=> length($a) || $a cmp $b} keys %EXTS);
our $RE_NOCI = qr/\A(.+)($RE_STR)\z/;
our $RE_CI   = qr/\A(.+)($RE_STR)\z/i;

our %SPEC;

$SPEC{check_executable_filename} = {
    v => 1.1,
    summary => 'Check whether filename indicates being an executable program/script',
    description => <<'_',


_
    args => {
        filename => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        # XXX recurse?
        ci => {
            summary => 'Whether to match case-insensitively',
            schema  => 'bool',
            default => 1,
        },
    },
    result_naked => 1,
    result => {
        schema => ['any*', of=>['bool*', 'hash*']],
        description => <<'_',

Return false if no archive suffixes detected. Otherwise return a hash of
information, which contains these keys: `exec_type`, `exec_ext`,
`exec_name`.

_
    },
    examples => [
        {
            args => {filename => 'foo.pm'},
            naked_result => 0,
        },
        {
            args => {filename => 'foo.appimage'},
            naked_result => {exec_name=>'foo', exec_type=>'appimage', exec_ext=>'.appimage'},
        },
        {
            summary => 'Case-insensitive by default',
            args => {filename => 'foo.Appimage'},
            naked_result => {exec_name=>'foo', exec_type=>'appimage', exec_ext=>'.Appimage'},
        },
        {
            summary => 'Case-sensitive',
            args => {filename => 'foo.Appimage', ci=>0},
            naked_result => 0,
        },
    ],
};
sub check_executable_filename {
    my %args = @_;

    my $filename = $args{filename};
    my $ci = $args{ci} // 1;

    #use DD; dd \%EXTS;
    my ($name, $ext) = $filename =~ ($ci ? $RE_CI : $RE_NOCI)
        or return 0;
    return {
        exec_name => $name,
        exec_ext  => $ext,
        exec_type => $EXTS{lc $ext},
    };
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Filename::Executable qw(check_executable_filename);
 my $res = check_executable_filename(filename => "foo.sh");
 if ($res) {
     printf "File is an executable (type: %s, ext: %s)\n",
         $res->{exec_type},
         $res->{exec_ext};
 } else {
     print "File is not an executable\n";
 }

=head1 DESCRIPTION


=head1 SEE ALSO

=cut
