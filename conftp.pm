#!/usr/bin/perl
package conftp;
use Net::FTP;
use POSIX;
use conf;
use record;
use Data::Dumper;
use File::Basename;
########################
# 段宏伟
# 2020-04-10
########################

##################################################################
sub getFtp    
##################################################################
{
	my ( $host,$user,$passwd,$remote_path)=@_;
	#创建ftp对象
	my $ftp;
	my %connStr=('host'=>$host,'user'=>$user,'passwd'=>$passwd);
	
	print Dumper %connStr;
	
	my $ftp=Net::FTP->new ($connStr{'host'},Passive=>0,Timeout=>30) or die("Can not connnect to ftp server ".$connStr{'host'}.$!);
	$ftp->login($user,$passwd) or die "Can not login"; #$ftp->message;
	return $ftp;
}


sub switch_server(){
	    my $pass1=encryp_dencryp("ftp862");
	    my $pass2=encryp_dencryp("ds_ftp_862");
		my %conStr=(
	   '122gen'=>"10.254.173.122,ftp862,${pass1},/"
	   ,'122ftp000'=>"10.254.173.122,ftp862,${pass1},/ftp000/"
	   ,'122hr_day'=>"10.254.173.122,ds_ftp_862,${pass2},/DayData/"
	   ,'122hr_month'=>"10.254.173.122,ds_ftp_862,${pass2},/MonthData/"
	   ,'122hr_iot862'=>"10.254.173.122,ds_ftp_862,${pass2},/iot862/"
	);
	while((my $key,my $value)=each%conStr)
	{
	     my ( $host,$user,$passwd,$remote_path)=split /,/,$value;
	     my $ftp=getFtp($host,$user,$passwd,$remote_path);
	     if ($ftp!=null){
	     	    $ftp->binary;
	     		$ftp->cwd($remote_path) or die ("Can not into remote dir".$!."\n");
	     		my @list=$ftp->ls($remote_path);
	     		print "current_server:$host  dir:$remote_path\n";
	     		down_server_files($ftp,$remote_path,@list);
	     }
	     $ftp->quit;
	} 	
}

sub encryp_dencryp
{
	  my $user=shift @_;
	  my $pass='';
	  if($user eq 'ftp862'){
	     $pass=`echo 'ZnRwODYyIyQhJUAK' |openssl  base64  -d`;
	  }else{
	  	 $pass=`echo 'Tm0mWnlDXzE5Cg==' |openssl  base64  -d`;
	  }
	  $pass=~s/[\r\n]//;
	  return ($pass);
}

sub down_server_files(){
	my ($ftp,$remote_path,@list)=@_;
	my $localdir='/pardata/EDADATA/JT_SOURCE/TEMP/NEWDATA/';
	my $count=0;
	my $current_month=strftime("%Y%m",localtime(time()));
	my @cvd_list=grep { /.CHECK|.gz|.VAL$/ } @list;
    for(@cvd_list){
		 my($file, $dir, $ext) = fileparse($_, qr/\.[^.]*/);
		 my $filename=$file.$ext;
		 my @namestr=split /\./ ,$filename;
		 if($namestr[1]=~/$current_month/){
		 	my $isdown=record::read_record($filename);
		 	if(record::read_record($filename)==0){
		 		print $filename."---".$isdown."\n";
		 		my $localfile=$localdir.$filename;
		 		my $remotefile=$remote_path.$filename;
		 		print "$remotefile>>>>$localfile\n";
				$ftp->get($remotefile,$localfile) or die "Could not get remotefile:$remotefile.\n";
		 		record::write_record($filename);
		 	}
		 }
    }
}

1;
