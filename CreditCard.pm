package Business::CreditCard;

# Business::CreditCard.pm
#
# Jon Orwant, <orwant@media.mit.edu>
#
# 12 Jul 96 - created
# 17 Jan 97 - 0.21 released.
#             short numbers and numbers with letters are no longer kosher.
# 1 Feb 2001 - 0.22 released, new maintainer, MakeMaker installation
# 3 May 2001 - 0.23 released, silly bug in test.pl
#
# Copyright 1995,1996,1997 Jon Orwant.  All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# 
# Version 0.23.  Module list status is "Rdpf."

require 5;

require Exporter;
use vars qw( @ISA $VERSION );

@ISA = qw( Exporter );

$VERSION = "0.23";

=head1 NAME

C<Business::CreditCard> - Validate/generate credit card checksums/names

=head1 SYNOPSIS

    use Business::CreditCard;
 
    print validate("5276 4400 6542 1319");
    print cardtype("5276 4400 6542 1319");
    print generate_last_digit("5276 4400 6542 131");

Business::CreditCard is available at a CPAN site near you.

=head1 DESCRIPTION

These subroutines tell you whether a credit card number is
self-consistent -- whether the last digit of the number is a valid
checksum for the preceding digits.  

The validate() subroutine returns 1 if the card number provided passes
the checksum test, and 0 otherwise.

The cardtype() subroutine returns a string containing the type of
card: "MasterCard", "VISA", and so on.  My list is not complete;
I welcome additions.

The generate_last_digit() subroutine computes and returns the last
digit of the card given the preceding digits.  With a 16-digit card,
you provide the first 15 digits; the subroutine returns the sixteenth.

This module does I<not> tell you whether the number is on an actual
card, only whether it might conceivably be on a real card.  To verify
whether a card is real, or whether it's been stolen, or what its
balance is, you need a Merchant ID, which gives you access to credit
card databases.  The Perl Journal (http://tpj.com/tpj) has
a Merchant ID so that I can accept MasterCard and VISA payments; it
comes with the little pushbutton/slide-your-card-through device you've
seen in restaurants and stores.  That device calculates the checksum
for you, so I don't actually use this module.

These subroutines will also work if you provide the arguments
as numbers instead of strings, e.g. C<validate(5276440065421319)>.  

=head1 AUTHOR

Jon Orwant

The Perl Journal and MIT Media Lab

orwant@tpj.com

Current maintainer is Ivan Kohler <ivan-business-creditcard@420.am>.
Please don't bother Jon with emails about this module.

=cut

@EXPORT = qw(cardtype validate generate_last_digit);

sub cardtype {
    my ($number) = @_;

    return "Not a credit card" if $number =~ /[^\d\s]/;

    $number =~ s/\D//g;

    return "Not a credit card" unless length($number) >= 13 && 0+$number;

    return "VISA card" if substr($number,0,1) == "4";
    return "MasterCard" if substr($number,0,1) == "5";
    return "Discover card" if substr($number,0,1) == "6";
    return "American Express card" if substr($number,0,2) == "37";
    return "Diner's Club, Transmedia, or other dining/entertainment card" if substr($number,0,1) == "3";
    return "Unknown";
}

sub generate_last_digit {
    my ($number) = @_;
    my ($i, $sum, $weight);

    $number =~ s/\D//g;

    for ($i = 0; $i < length($number); $i++) {
	$weight = substr($number, -1 * ($i + 1), 1) * (2 - ($i % 2));
	$sum += (($weight < 10) ? $weight : ($weight - 9));
    }

    return (10 - $sum % 10) % 10;
}

sub validate {
    my ($number) = @_;
    my ($i, $sum, $weight);
    
    return 0 if $number =~ /[^\d\s]/;

    $number =~ s/\D//g;

    return 0 unless length($number) >= 13 && 0+$number;

    for ($i = 0; $i < length($number) - 1; $i++) {
	$weight = substr($number, -1 * ($i + 2), 1) * (2 - ($i % 2));
	$sum += (($weight < 10) ? $weight : ($weight - 9));
    }

    return 1 if substr($number, -1) == (10 - $sum % 10) % 10;
    return 0;
}

1;


