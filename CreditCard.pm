package Business::CreditCard;

# Jon Orwant, <orwant@media.mit.edu>
#
# Copyright 1995,1996,1997 Jon Orwant.  All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Current maintainer is Ivan Kohler <ivan-business-creditcard@420.am>.
# Please don't bother Jon with emails about this module.

require 5;

require Exporter;
use vars qw( @ISA $VERSION );

@ISA = qw( Exporter );

$VERSION = "0.28";

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
card.  My list is not complete; I welcome additions.

Possible return values are:

  VISA card
  MasterCard
  Discover card
  American Express card
  Diner's Club/Carte Blanche
  enRoute
  JCB
  BankCard
  Switch
  Solo
  Unknown

"Not a credit card" is returned on obviously invalid
data values.

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

Lee Lawrence <LeeL@aspin.co.uk>, Neale Banks <neale@lowendale.com.au> and
Max Becker <Max.Becker@firstgate.com> contributed support for additional card
types.  Lee also contributed a working test.pl.

=cut

@EXPORT = qw(cardtype validate generate_last_digit);

sub cardtype {
    my ($number) = @_;

    return "Not a credit card" if $number =~ /[^\d\s]/;

    $number =~ s/\D//g;

    return "Not a credit card" unless length($number) >= 13 && 0+$number;

    return "VISA card" if $number =~ /^4\d{12}(\d{3})?$/o;
    return "MasterCard" if $number =~ /^5[1-5]\d{14}$/o;
    return "Discover card" if $number =~ /^6011\d{12}$/o;
    return "American Express card" if $number =~ /^3[47]\d{13}$/o;
    return "Diner's Club/Carte Blanche"
      if $number =~ /^3(0[0-5]|[68]\d)\d{11}$/o;
    return "enRoute" if $number =~ /^2(014|149)\d{11}$/o;
    return "JCB" if $number =~ /^(3\d{4}|2131|1800)\d{11}$/o;
    return "BankCard" if $number =~ /^56(10\d\d|022[1-5])\d{10}$/o;
    return "Switch"
      if $number =~ /^49(03(0[2-9]|3[5-9])|11(0[1-2]|7[4-9]|8[1-2])|36[0-9]{2})\d{10}(\d{2,3})?$/o
      || $number =~ /^564182\d{10}(\d{2,3})?$/o
      || $number =~ /^6(3(33[0-4][0-9])|759[0-9]{2})\d{10}(\d{2,3})?$/o;
    return "Solo"
      if $number =~ /^6(3(34[5-9][0-9])|767[0-9]{2})\d{10}(\d{2,3})?$/o;
    return "Unknown";
}

# from http://perl.about.com/compute/perl/library/nosearch/P073000.htm
# verified by http://www.beachnet.com/~hstiles/cardtype.html
# Card Type                         Prefix                           Length
# MasterCard                        51-55                            16
# VISA                              4                                13, 16
# American Express (AMEX)           34, 37                           15
# Diners Club/Carte Blanche         300-305, 36, 38                  14
# enRoute                           2014, 2149                       15
# Discover                          6011                             16
# JCB                               3                                16
# JCB                               2131, 1800                       15
#
# from Neale Banks <neale@lowendale.com.au>
# According to a booklet I have from Westpac (an Aussie bank), a card number
# starting with 5610 or 56022[1-5] is a BankCard
# BankCards have exactly 16 digits.
#
# from "Becker, Max" <Max.Becker@firstgate.com>
# It's mostly used in the UK and is either called "Switch" or "Solo".
# Card Type                         Prefix                           Length
# Switch                            various                          16,18,19
# Solo                              63, 6767                         16,18,19

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


