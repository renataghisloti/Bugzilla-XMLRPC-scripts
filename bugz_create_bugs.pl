#!/usr/bin/perl -w
############################################################
#                                                           #
# Script to create bugs via XMLRPC                          #
# Usage: perl script.pl file                                #
# Author: Renata Ghisloti <renataghisloti@gmail.com>        #
#                                                           #
############################################################


use strict;
use lib qw(lib);
use XMLRPC::Lite;
use Data::Dumper;


# Put here your own Bugzilla account information
# and the bugzilla uri you want to access
use constant USER_LOGIN     => '***';
use constant PWD            => '###';
use constant BUGZILLA_URI   => 'https://bugzilla.com/xmlrpc.cgi';

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

# Create bug - make sure to change it to your own bug info
$soapresult = $proxy->call('Bug.create', { 
                                           product   => "Myfamily",
  				   component => "MyComponent",
                                           summary   => "Unit Test: My Example Bug",
                                           severity  => "block",
                                           platform  => "PPC-64",           # Architecture
                                           version   => "unspecified",
					   login_token => $token });
_die_on_fault($soapresult);

my $result = $soapresult->result();
warn Dumper($result);

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
