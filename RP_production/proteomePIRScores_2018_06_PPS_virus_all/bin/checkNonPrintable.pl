while (<FILE>) {
    print;

    s/^\s+//; # remove leading spaces
    s/\s+$//; # remove trailing spaces

    if (/[\x00-\x1F]/) {
        print "WARNING -- Non-printables were found; they have been detected.";
    }
}
