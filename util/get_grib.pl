#!/usr/bin/perl -w
$curl="/usr/bin/curl";

# get_grib.pl            wesley ebisuzaki
# v0.9  1/2005
#
# gets a grib file from the net, uses a wgrib inventory with a 
#   "range inventory" to control the ftp/http/https transfer
#
# requires:
#   curl:   http://curl.haxx.se open source MIT/X derivate license
#   perl:   open source
#
# configuration:
#   line 1:  #!{location of perl} -w
#   line 2:  curl="{location of curl executable}";
#
# v0.9.5 6/2006 error with grib-1, last record
# v0.9.6 10/2006 better error return codes
# v0.9.7 4/2017 allow https

$version="get_grib.pl v0.9.7 4/2017 wesley ebisuzaki\n";

$file="";
$url="";

foreach $_ (@ARGV) {
  SWITCH: {
    /^-v$|^--version$/ && do { print   $version; exit 8; };
    /^http:|^https:/ && do {
	 if ($url eq '') { $url = $_; last SWITCH; }
	 else {
	   print   "error: multiple URLs found\n";
	   exit 8;
	 }
      };
    /^-h$|^--help$/ && do {
        print   "\n$0: gets selected grib records from net\n";
        print   "   usage: cat {enhanced wgrib inv} | grep FIELD | $0 URL-of-gribfile output-file\n\n";
        print   "   ex: get_inv.pl http://nomad3.ncep.noaa.gov/pub/gfs/rotating/gblav.t00z.pgrbf12.inv | \\\n";
        print   "       grep \":HGT:500 mb:\" | \\\n";
        print   "       $0  http://nomad3.ncep.noaa.gov/pub/gfs/rotating/gblav.t00z.pgrbf12 out.grb\n\n";
        print   "This program is part of a package to select GRIB records (messages)\n";
        print   "to download.  By selecting specific records, the download times can\n";
        print   "be significantly reduced.  This program uses cURL and supports grib\n";
        print   "data on http: (most) and ftp: servers that include wgrib inventories.\n";
        print   "ref: http://www.cpc.ncep.noaa.gov/products/wesley/fast_downloading_grib.html\n";
        exit 8;
      };
    if ($file eq "") {
      $file = $_;
      last SWITCH;
    }
    print   "error: multiple URLs found\n";
    sleep(5);
    exit 8;
  }
}

if ($file eq '' || $url eq '') {
  print   $version;
  print   "\n$0: gets gribfile from net using wgrib inventory with range field\n";
  print   "   usage: cat {wgrib inv with range field} | $0 URL-of-wgrib-inventory OUTPUT-FILE\n";
  if ($file eq '') {
    print   "\n\n  MISING OUTPUT-FILE!\n\n";
  }
  else {
    print   "\n\n  MISING URL!\n\n";
  }
  exit 8;
}


$range="";
$lastfrom='';
$lastto=-100;
while (<STDIN>) {
  chomp;
  $from='';
  /:range=([0-9]*)/ && do {$from=$1};
  $to='';
  /:range=[0-9]*-([0-9]*)/ && do {$to=$1};

  if ($lastto+1 == $from) {
#   delay writing out last range specification
    $lastto = $to;
  }
  elsif ($lastto ne $to) {
#   write out last range specification
    if ($lastfrom ne '') {
       if ($range eq '') { $range="$lastfrom-$lastto"; }
       else { $range="$range,$lastfrom-$lastto"; }
    }
    $lastfrom=$from;
    $lastto=$to;
  }
#  print "$_\n";
}
if ($lastfrom ne '') {
  if ($range eq '') { $range="$lastfrom-$lastto"; }
  else { $range="$range,$lastfrom-$lastto"; }
}

unlink $file;
if ($range ne "") {
   $err=system("$curl -f -v -s -r \"$range\" $url -o $file.tmp");
   $err = $err >> 8;
   if ($err != 0) {
      print   "error in getting file $err\n";
      sleep(20);
      exit $err;
   }
   if (! rename "$file.tmp",  "$file") {
      sleep(30);
   }
}
else {
  sleep(10);
  print   "No download! No matching grib fields\n";
  sleep(30);
  exit 8;
}

exit 0;
