package Netgear::WGT624;

use 5.008;

use strict;
use warnings;

our $VERSION = '0.03';

use LWP::UserAgent;

sub new {
    my $self = {};

    # Credentials necessary for connecting to router web interface.
    $self->{USERNAME} = undef;
    $self->{PASSWORD} = undef;
    $self->{ADDRESS}  = undef;
    $self->{STATS}     = undef;
    
    bless($self);
    return $self;
}


###### BEGIN Private methods protected using closures.
my $query_device = sub {

    my $self = shift;

    my $resref = $self->fetch_html;

    my @vals = grep( /<span class="ttext">/, @$resref );

    my @retvals = ();

    foreach my $val (@vals) {
	if ($val =~ m/span class="ttext">(.*?)<\/span>/) {
	    push (@retvals, $1); 
	}
    }

    $self->{STATS} = {
	WAN_Status      => $retvals[0],
	WAN_TxPkts      => $retvals[1],
	WAN_RxPkts      => $retvals[2],
	WAN_Collisions  => $retvals[3],
	WAN_TxRate      => $retvals[4],
	WAN_RxRate      => $retvals[5],
	WAN_UpTime      => $retvals[6],

	LAN_Status      => $retvals[7],
	LAN_TxPkts      => $retvals[8],
	LAN_RxPkts      => $retvals[9],
	LAN_Collisions  => $retvals[10],
	LAN_TxRate      => $retvals[11],
	LAN_RxRate      => $retvals[12],
	LAN_UpTime      => $retvals[13],

	WLAN_Status     => $retvals[14],
	WLAN_TxPkts     => $retvals[15],
	WLAN_RxPkts     => $retvals[16],
	WLAN_Collisions => $retvals[17],
	WLAN_TxRate     => $retvals[18],
	WLAN_RxRate     => $retvals[19],
	WLAN_UpTime     => $retvals[20],
    };

};

###### END Private methods protected using closures.

sub username($) {
    my $self = shift;
    if (@_) { $self->{USERNAME} = shift; }
    return $self->{USERNAME};
}

sub password($) {
    my $self = shift;
    if (@_) { $self->{PASSWORD} = shift; }
    return $self->{PASSWORD};
}

sub address($) {
    my $self = shift;
    if (@_) { $self->{ADDRESS} = shift; }
    return $self->{ADDRESS};
}

sub getStatistic($$) {
    my $self = shift;
    my $param = shift;

    # Refresh our data structure containing the TxRate.
    $self->$query_device;

    return $self->{STATS}->{$param};
}

# get_server_address - Make sure that address is really a 
# server address, i.e., chop off prepending http:// and 
# slashes if found.  Return the default port of 80
# for the netgear device.
sub get_server_address {
    my $self = shift;
    
    my $address = $self->{ADDRESS};
    $address =~ s/^http:\/\///;
    $address =~ s/\/$//;

    $address .= ':80';

    return $address;
}

# fetch_html - gets the HTML from Netgear router using LWP.
sub fetch_html {
    my $self = shift;

    my $username = $self->{USERNAME};
    my $password = $self->{PASSWORD};
    my $address  = $self->{ADDRESS};

    my $url = $self->make_url;

    # Use the LWP library to download the HTML page into array @html.
    my $ua = LWP::UserAgent->new();

    $ua->timeout(10);

    $ua->env_proxy;  # Use proxy environment vars, if defined.

    $ua->credentials($self->get_server_address,
		     'WGT624',
		     $username,
		     $password);

    my $response = $ua->get($url);
    
    my @html = ();

    if ($response->is_success) {
	@html = split(/\n/, $response->content);
    } else {
	die "Error: Server returned error message: " . $response->status_line;
    }
    
    return \@html;
}

# make_url - generates the URL from input address.
sub make_url {
    my $self = shift;

    my $url = $self->{ADDRESS};

    # If the address doesn't have http:// prepended, add it.
    if (!($url =~ m/^http:\/\//)) {
	$url = 'http://' . $url;
    }

    # If the address ends in a slash, chop it off because it 
    # won't be necessary after next op.
    $url =~ s/\/$//;

    $url = $url . "/RST_stattbl.htm";

    return $url;
}

1;

__END__

=head1 NAME

Netgear::WGT624 - Queries a Netgear WGT624 (108 Mbps Firewall Router) 
for state information.

=head1 SYNOPSIS

use Netgear::WGT624;

=head1 DESCRIPTION

Netgear::WGT624 is the library that supports programs that query the
Netgear WGT624 for state information over HTTP.

=head2 EXPORT

None by default.

=head1 SEE ALSO

The man page for get-wgt624-statistics.

The author of this software has his web page at http://justin.phq.org/.

=head1 AUTHOR

Justin S. Leitgeb, E<lt>justin@phq.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Justin S. Leitgeb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
