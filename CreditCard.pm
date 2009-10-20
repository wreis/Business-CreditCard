package Business::CreditCard;

require Exporter;
use vars qw( @ISA $VERSION $Country );

@ISA = qw( Exporter );

$VERSION = "0.31";

$Country = 'US';

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
card.  The list of possible return values is more comprehensive than it used
to be, but additions are still most welcome.

Possible return values are:

  VISA card
  MasterCard
  Discover card
  American Express card
  enRoute
  JCB
  BankCard
  Switch
  Solo
  China Union Pay
  Laser
  Unknown

"Not a credit card" is returned on obviously invalid data values.

Versions before 0.31 may also have returned "Diner's Club/Carte Blanche" (these
cards are now recognized as "Discover card").

As of 0.30, cardtype() will accept a partial card masked with "x", "X', ".",
"*" or "_".  Only the first 2-6 digits and the length are significant;
whitespace and dashes are removed.  To recognize just Visa, MasterCard and
Amex, you only need the first two digits; to recognize almost all cards
except some Switch cards, you need the first four digits, and to recognize
all cards including the remaining Switch cards, you need the first six
digits.

The generate_last_digit() subroutine computes and returns the last
digit of the card given the preceding digits.  With a 16-digit card,
you provide the first 15 digits; the subroutine returns the sixteenth.

This module does I<not> tell you whether the number is on an actual
card, only whether it might conceivably be on a real card.  To verify
whether a card is real, or whether it's been stolen, or to actually process
charges, you need a Merchant account.  See L<Business::OnlinePayment>.

These subroutines will also work if you provide the arguments
as numbers instead of strings, e.g. C<validate(5276440065421319)>.  

=head1 PROCESSING AGREEMENTS

Credit card issuers have recently been forming agreements to process cards on
other networks, in which one type of card is processed as another card type.

By default, Business::CreditCard returns the type the card should be treated as
in the US and Canada.  You can change this to return the type the card should
be treated as in a different country by setting
C<$Business::CreditCard::Country> to your two-letter country code.  This
is probably what you want to determine if you accept the card, or which
merchant agreement it is processed through.

You can also set C<$Business::CreditCard::Country> to a false value such
as the empty string to return the "base" card type.  This is probably only
useful for informational purposes when used along with the default type.

Here are the currently known agreements:

=over 4

=item Most Diner's club is now identified as Discover.  (This supercedes the earlier identification of some Diner's club cards as MasterCard inside the US and Canada.)

=item JCB cards in the 3528-3589 range are identified as Discover inside the US and Canada.

=item China Union Pay cards are identified as Discover cards outside China.

=back

=head1 NOTE ON INTENDED PURPOSE

This module is for verifying I<real world> B<credit cards>.  It is B<NOT> a
pedantic implementation of the ISO 7812 standard, a general-purpose LUHN
implementation, or intended for use with "creditcard-like account numbers".

=head1 AUTHOR

Jon Orwant

The Perl Journal and MIT Media Lab

orwant@tpj.com

Current maintainer is Ivan Kohler <ivan-business-creditcard@420.am>.
Please don't bother Jon with emails about this module.

Lee Lawrence <LeeL@aspin.co.uk>, Neale Banks <neale@lowendale.com.au> and
Max Becker <Max.Becker@firstgate.com> contributed support for additional card
types.  Lee also contributed a working test.pl.  Alexandr Ciornii
<alexchorny@gmail.com> contributed code cleanups.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1995,1996,1997 Jon Orwant
Copyright (C) 2001-2006 Ivan Kohler
Copyright (C) 2007-2009 Freeside Internet Services, Inc.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

L<Business::CreditCard::Object> is a wrapper around Business::CreditCard
providing an OO interface.  Assistance integrating this into the base
Business::CreditCard distribution is welcome.

L<Business::OnlinePayment> is a framework for processing online payments
including modules for various payment gateways.

=cut

@EXPORT = qw(cardtype validate generate_last_digit);

sub cardtype {
    my ($number) = @_;

    $number =~ s/[\s\-]//go;
    $number =~ s/[x\*\.\_]/x/gio;

    return "Not a credit card" if $number =~ /[^\dx]/io;

    #$number =~ s/\D//g;
    {
      local $^W=0; #no warning at next line
      return "Not a credit card" unless length($number) >= 13 && 0+$number;
    }

    return "Switch"
      if $number =~ /^49(03(0[2-9]|3[5-9])|11(0[1-2]|7[4-9]|8[1-2])|36[0-9]{2})[\dx]{10}([\dx]{2,3})?$/o
      || $number =~ /^564182[\dx]{10}([\dx]{2,3})?$/o
      || $number =~ /^6(3(33[0-4][0-9])|759[0-9]{2})[\dx]{10}([\dx]{2,3})?$/o;

    return "VISA card" if $number =~ /^4[\dx]{12}([\dx]{3})?$/o;

    return "MasterCard"
      if   $number =~ /^5[1-5][\dx]{14}$/o
      ;# || ( $number =~ /^36[\dx]{12}/ && $Country =~ /^(US|CA)$/oi );

    return "Discover card"
      if   $number =~ /^30[0-5][\dx]{11}([\dx]{2})?$/o  #diner's: 300-305
      ||   $number =~ /^3095[\dx]{10}([\dx]{2})?$/o     #diner's: 3095
      ||   $number =~ /^3[68][\dx]{12}([\dx]{2})?$/o    #diner's: 36
      ||   $number =~ /^6011[\dx]{12}$/o
      ||   $number =~ /^64[4-9][\dx]{13}$/o
      ||   $number =~ /^65[\dx]{14}$/o
      || ( $number =~ /^62[24-68][\dx]{13}$/o && uc($Country) ne 'CN' ) #CUP
      || ( $number =~ /^35(2[89]|[3-8][\dx])[\dx]{10}$/o && uc($Country) eq 'US' );

    return "American Express card" if $number =~ /^3[47][\dx]{13}$/o;

    #return "Diner's Club/Carte Blanche"
    #  if $number =~ /^3(0[0-59]|[68][\dx])[\dx]{11}$/o;

    #"Diners Club enRoute"
    return "enRoute" if $number =~ /^2(014|149)[\dx]{11}$/o;

    return "JCB" if $number =~ /^(3[\dx]{4}|2131|1800)[\dx]{11}$/o;

    return "BankCard" if $number =~ /^56(10[\dx][\dx]|022[1-5])[\dx]{10}$/o;

    return "Solo"
      if $number =~ /^6(3(34[5-9][0-9])|767[0-9]{2})[\dx]{10}([\dx]{2,3})?$/o;

    return "China Union Pay"
      if $number =~ /^62[24-68][\dx]{13}$/o;

    return "Laser"
      if $number =~ /^6(304|7(06|09|71))[\dx]{12,15}$/o;

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


