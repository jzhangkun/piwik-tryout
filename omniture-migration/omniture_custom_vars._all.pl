#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

my %prop;  # Traffic Property
my %evar;  # Conversion Variable
my %event; # Event
while (<>) {
  #print;
  parse_prop(\%prop, $') if m{^Traffic Property\s+};
  parse_evar(\%evar, $') if m{^Conversion Variable\s+};
  parse_event(\%event,$') if m{^Event\s+};
}

exit 0 if !%prop && !%evar && !%event;

print Dumper \%prop;
print Dumper \%evar;
print Dumper \%event;

output_std('prop', \%prop);
output_std('eVar', \%evar);
output_std('custom event', $event{Custom}) if exists $event{Custom};
output_std('standard event', $event{Standard}) if exists $event{Standard};

exit 0;

sub output_std {
  my ($prefix, $rh) = @_;
  for my $k (sort { $a <=> $b } keys %$rh) {
    print "${prefix}$k = ", join(', ' => uniq(map $_->{Name}, @{$rh->{$k}})), "\n";
  }
}

sub uniq {
  my %hUniq;
  return (grep { !$hUniq{$_}++ } @_);
}

sub parse_prop {
  my ($rh, $line) = @_;
  if ($line =~ m{^Traffic Property (\d+): (.+)}) {
    my ($id, $attr) = ($1, $2);
    my @attrs = split /, / => $attr;
    my $name = (split /=/, $attrs[0])[1];
    my $status = $attrs[1];
    push @{ $rh->{$id} } => {
      Name => $name,
      Status => $status,
    };
  }
}

sub parse_evar {
  my ($rh, $line) = @_;
  #print $line;
  if ($line =~ m{^Conversion Variable (\d+)[.] Status : (Enabled|Disabled) Name : (.+?) Type : .+}) {
    my ($id, $status, $name) = ($1, $2, $3);
    return if $status eq 'Disabled';
    push @{ $rh->{$id} } => {
      Name => $name,
      Status => $status
    };
  }
}

sub parse_event {
  my ($rh, $line) = @_;
  #print $line;
  if ($line =~ m{^(Custom|Standard) Event (\d+): (.+)}) {
    my ($event, $id, $attr) = ($1, $2, $3);
    my %attr;
    # Name, Type etc...
    for my $field (split /: / => $attr) {
      my ($k, $v) = split /=/, $field;
      $attr{$k} = $v;
    }
    # skip the event name with "Custom", they're not in use probably
    return if $attr{Name} =~ m{^Custom \d+};
    push @{ $rh->{$event}{$id} } => \%attr;
  }
}
