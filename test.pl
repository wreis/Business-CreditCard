# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Business::CreditCard;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

#test 2
if( test_card_identification() ){ print "ok 2\n" }else{ print "not ok 2\n" }

sub test_card_identification{
        # 
        # For the curious the table of test number aren't real credit card
        # in fact they won't validate but they do obey the rule for the
        # cardtype table to identify the card type.
        #
        my %test_table=(
                '5212345678901234' =>   'MasterCard',
                '5512345678901234' =>   'MasterCard',
                '4123456789012' =>      'VISA card',
                '4512345678901234' =>   'VISA card',
                '341234567890123' =>    'American Express card',
                '371234567890123' =>    'American Express card',
                '30112345678901' =>     "Diner's Club/Carte Blanche",
                '30512345678901' =>     "Diner's Club/Carte Blanche",
                '36123456789012' =>     "Diner's Club/Carte Blanche",
                '38123456789012' =>     "Diner's Club/Carte Blanche",
                '201412345678901' =>    'enRoute',
                '214912345678901' =>    'enRoute',
                '6011123456789012' =>   'Discover card',
                '3123456789012345' =>   'JCB',
                '213112345678901' =>    'JCB',
                '180012345678901' =>    'JCB',
                '1800123456789012' =>   'Unknown',
                '312345678901234' =>    'Unknown',
        );
        while( my ($k, $v)=each(%test_table) ){
                if(cardtype($k) ne $v){
                        print "Card $k - should be $v cardtpe returns ",cardtype
($k),"\n";
                        return;
                }
        }
        return 1;
}

