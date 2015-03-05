#!/usr/bin/perl

use Device::Modem;   # apt-get libdevice-modem-perl
use strict;

my $ESC=chr(0x1B);
my $EOL=$ESC."[K\n";

my $pin="0703";

my $modem = new Device::Modem( port => '/dev/ttyUSB2' );

if( $modem->connect( baudrate => 9600 ) ) {
  print "connected!\n";
} else {
  print "sorry, no connection with serial port!\n";
}

$modem->atsend( 'AT+CPIN?' . Device::Modem::CR);
if ($modem->answer() =~ /CPIN: SIM PIN/) {
  $modem->atsend( 'AT+CPIN="'.$pin.'"' . Device::Modem::CR);
  print $modem->answer();
}
  
$modem->atsend( 'AT+CGREG=2' . Device::Modem::CR); # Set Long CGREG output
$modem->answer();
$modem->atsend( 'AT+COPS=3,0' . Device::Modem::CR); # Set Long Alphanumeric Oper
$modem->answer();
  
print $ESC,"[2J";
  
while (1) {
  print $ESC,"[0;0f";

  $modem->atsend( 'AT+CSQ' . Device::Modem::CR);
  my $res=$modem->answer();
  $res=~/CSQ: (\d+),(\d+)/;
  
  my $rssi=$1;
  my $ber=$2;
  
  my $dbm=($rssi * 2) -113;
  
  print "Signal              : $dbm dBm, RSSI: $rssi, BER: $ber".$EOL;
  
  $modem->atsend( 'AT+COPS?' . Device::Modem::CR);  # Operator ?
  $res = $modem->answer(). "\n";
  $res=~/COPS: (\d+),(\d+),\"([^"]+)\",(\d+)/;  # +COPS: 0,2,"22801",2
  my @modes=("Automatic", "Manual", "Deregister", "Manual/Automatic");
  my @stat=("Unknown","Available","Current","Forbidden");
  print "Mode                : ".$modes[$1].$EOL;
  print "Operator            : ".$3.$EOL;
  print "Status              : ".$stat[$4].$EOL;
#  print $res;
  
  my $res="";
  $modem->atsend( 'AT+CGREG?' . Device::Modem::CR); # Registration Status
  $res = $modem->answer(). "\n";
  $res=~/CGREG: (\d+),(\d+),\s*([0-9A-F]+),\s*([0-9A-F]+),?\s*(\d)?/;  # +CGREG: 0,1   #+CGREG: 2,   1,     100F9, 905C   
                                               #        <n>,<stat>[,<lac>,<ci>[,<AcT>]]
  my @stat=("Not registered", "Registered, home network", "Not registered, Searching", "Registration denied", "Unknown", "Registered, roaming");
  print "Registration Status : ".$stat[$2].$EOL;
  print "Location Area Code  : ".$3.$EOL;
  print "Cell ID             : ".$4.$EOL;
  if ($5) {
    print "Access Technology   : ".$5.$EOL;
  }

#0 GSM
#1 GSM Compact
#2 UTRAN
#3 GSM w/EGPRS (see NOTE 1)
#4 UTRAN w/HSDPA (see NOTE 2)
#5 UTRAN w/HSUPA (see NOTE 2)
#6 UTRAN w/HSDPA and HSUPA (see NOTE 2)

  
#  print $res;
  sleep (1);
}