# NAME

DB::Berkeley - XS-based OO Berkeley DB HASH interface

# SYNOPSIS

    use DB::Berkeley;

    my $db = DB::Berkeley->new(Filename => 'my.db');

    $db->put("foo", "bar");
    my $val = $db->get("foo");
    $db->delete("foo");

# DESCRIPTION

A lightweight XS wrapper around Berkeley DB using HASH format, without using tie().
DB\_File works, I just prefer this API.

# SEE ALSO

[DB\_File](https://metacpan.org/pod/DB_File)
