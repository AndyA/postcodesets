#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Text::CSV_XS;

my $data = {};

my @iter = ();

my %exclude = ( row => 1 );

for my $file (@ARGV) {
  push @iter, { i => csv_iter($file), v => undef };
}

my $set_size = @iter;

my %cols = ();

for my $iter (@iter) {
  my $row = $iter->{i}();
  $iter->{c} = $row;
  $cols{$_}++ for @$row;
}

delete $cols{$_} for keys %exclude;
delete $cols{postcode};
my @cols = ( 'postcode', sort keys %cols );
print csv( 'row', @cols ), "\n";

my $rn = 1;
while ( @iter == $set_size ) {

  @iter = refill(@iter);

  my @now = sort { $a cmp $b } map { $_->{v}{postcode} } @iter;

  if ( $now[0] eq $now[-1] ) {
    my $rec = {};
    for my $i ( 0 .. $#iter ) {
      %{$rec} = ( %{$rec}, %{ $iter[$i]{v} } );
      $iter[$i]{v} = undef;
    }
    my @row = @{$rec}{@cols};
    print csv( $rn++, @row ), "\n";
  }
  else {
    for my $i ( 0 .. $#iter ) {
      next if $iter[$i]{v}{postcode} eq $now[-1];
      $iter[$i]{v} = undef;
    }
  }
}

sub csv { join ',', map defined $_ ? qq{"$_"} : '', @_ }

sub refill {
  my @iter  = @_;
  my @niter = ();
  for my $iter (@iter) {
    if ( defined $iter->{v} ) {
      push @niter, $iter;
      next;
    }

    my $nv = $iter->{i}();
    if ( defined $nv ) {
      my $rec = {};
      @{$rec}{ @{ $iter->{c} } } = @$nv;
      push @niter, { i => $iter->{i}, c => $iter->{c}, v => $rec }
       if defined $nv;
    }
  }
  return @niter;
}

sub csv_iter {
  my $file = shift;
  open my $fh, "<:encoding(utf8)", $file or die "Can't read $file: $!\n";
  my $csv = Text::CSV_XS->new;
  return sub { $csv->getline($fh) };
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

