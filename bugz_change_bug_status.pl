############################################################
#                                                           #
# Script to change bug status to CLOSED via XMLRPC          #
# Usage: perl script.pl bug_id                              #
# Author: Renata Ghisloti <renataghisloti@gmail.com>        #
#                                                           #
############################################################

#!/usr/bin/perl -w

use strict;
use lib qw(lib);
use Data::Dumper;
use XMLRPC::Lite;

# Put here your own Bugzilla account information
# and the bugzilla uri you want to access
use constant USER_LOGIN     => '***';
use constant PWD            => '###';
use constant BUGZILLA_URI   => 'https://bugzilla.com/xmlrpc.cgi';

# Get Bug 
my $bug = shift @ARGV;
defined $bug || die "Error: bug not specified.";

# Start accessing LTCBugzilla
my $proxy = XMLRPC::Lite->proxy(BUGZILLA_URI);

# Log in and get Token
my $soapresult;
$soapresult = $proxy->call('User.login',
                           { login    => USER_LOGIN,
                             password => PWD,
                             remember => 1 });

_die_on_fault($soapresult);

# Get token form login
my $token =  $soapresult->result()->{login_token};


# Call update method
$soapresult = $proxy->call('Bug.update',
                            { ids => $bug,
                              status => 'CLOSED',
                              login_token => $token,
                            });
_die_on_fault($soapresult);


print $soapresult->result();


########################################################
# Error method                                         #
########################################################

sub _die_on_fault {
    my $soapresult = shift;

    if ($soapresult->fault) {
        my ($package, $filename, $line) = caller;
        die $soapresult->faultcode . ' ' . $soapresult->faultstring .
            " in SOAP call near $filename line $line.\n";
    }
}
