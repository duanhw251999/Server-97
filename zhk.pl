#!/usr/bin/perl
use strict;
use FileHandle;
use Net: :FTP;
use Cwd;
use Date: :Calc qw(Date_to_Time Time_to_Date Add_Delta_Days);
use File: :Copy;
use Encode;
use POSIX;
main();
sub main() {
    abc123();
    abc456();
    abc789();
    abc000();
    abc7788();
}
sub abc7788() {
    my $current_date = strftime("%Y%m%d", localtime(time() - (3600 * 24) * 1));
    my $path0 = "E:/PERSONAL/Duanhw/zhk/$current_date/";
    my $path1 = 'E:/ETL/DATA/receive/';
    opendir DIR,
    $path0 || die "Error in opening dir $path0\n";
    my $filename = "";
    while (($filename = readdir(DIR))) {
        my $file_full = $path0.$filename;
        if ( - f $file_full) {
            move $file_full,
            $path1.$filename;
        }
    }
    closedir DIR
}
sub abc123 {
    my $rootPath = "E:/PERSONAL/Duanhw/zhk/";
    chdir($rootPath);
    opendir(DIRFILE, $rootPath);
    my@files = readdir(DIRFILE);
    foreach(@files) {
        if ($_ ! ~ / [.] / ) {
            if (length($_) == 42) {
                my $olddir = getcwd."/".$_;
                my $newdir = getcwd."/".substr($_, 28, 8);
                move $olddir,
                $newdir;
            }
        }
    }
    close DIRFILE;
}
sub abc456 {
    my $rootPath = "E:/PERSONAL/Duanhw/zhk/";
    chdir($rootPath);
    opendir(DIRFILE, $rootPath);
    my@files = readdir(DIRFILE);
    foreach(@files) {
        if ($_ ! ~ / [.] / ) {
            if (length($_) == 8) {
                my $zhangqi = $_;
                my $subdir = getcwd."/".$zhangqi."/*";
                my@subfiles = glob($subdir);
                foreach my $sf(@subfiles) {
                    my $oldfile = $sf;
                    my $newfile = getcwd."/".$zhangqi."/";
                    if (getFileName($oldfile) = ~ / ctei / ) {
                        $newfile = $newfile."s_${zhangqi}_13086_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / AidSale / ) {
                        $newfile = $newfile."s_${zhangqi}_13087_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / register / ) {
                        $newfile = $newfile."s_${zhangqi}_13088_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / bind / ) {
                        $newfile = $newfile."s_${zhangqi}_13089_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / gatewayInfo / ) {
                        $newfile = $newfile."s_${zhangqi}_13090_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / devNetData / ) {
                        $newfile = $newfile."s_${zhangqi}_13091_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / cloudBag / ) {
                        $newfile = $newfile."s_${zhangqi}_13092_01.dat";
                    }
                    elsif(getFileName($oldfile) = ~ / recommendRecord / ) {
                        $newfile = $newfile."s_${zhangqi}_13095_01.dat";
                    } else {
                        $newfile = "";
                    }
                    move $oldfile,
                    $newfile;
                }
            }
        }
    }
    close DIRFILE;
}
sub abc789 {
    my $rootPath = "E:/PERSONAL/Duanhw/zhk/";
    chdir($rootPath);
    opendir(DIRFILE, $rootPath);
    my@files = readdir(DIRFILE);
    foreach(@files) {
        if ($_ ! ~ / [.] / ) {
            if (length($_) == 8) {
                my $zhangqi = $_;
                my $subdir = getcwd."/".$zhangqi."/*";
                my@subfiles = glob($subdir);
                foreach my $sf(@subfiles) {
                    cut_tworow(getcwd."/".$zhangqi."/", getFileName($sf));
                }
            }
        }
    }
    close DIRFILE;
}
sub cut_tworow {
    my($path, $oldname) = @_;
    my $count = 0;
    my $newname = $path."temp.txt";
    open FILE,
    "<$path"."$oldname";
    open NEWFILE,
    ">$newname";
    while ( < FILE > ) {
        if ($count > 1) {
            print NEWFILE $_;
        }
        $count = $count + 1;
    }
    close FILE;
    close NEWFILE;
    unlink $path.$oldname;
    move $newname,
    $path.$oldname;
}
sub getFileName {
    my($path) = @_;
    my@Name = split(/\//, $path);
    my $num = 1;
    my $count = @Name;
    my $ind = $count - $num;
    my $fileName = $Name[$ind];
    return $fileName;
}
sub getFileSize {
    my($filename) = @_;
    my@args = stat($filename);
    my $size = $args[7];
    return $size;
}
sub abc000 {
    my $rootPath = "E:/PERSONAL/Duanhw/zhk/";
    chdir($rootPath);
    opendir(DIRFILE, $rootPath);
    my@files = readdir(DIRFILE);
    foreach(@files) {
        if ($_ ! ~ / [.] / ) {
            if (length($_) == 8) {
                my $zhangqi = $_;
                my $subdir = getcwd."/".$zhangqi."/*";
                my@subfiles = glob($subdir);
                foreach my $sf(@subfiles) {
                    my $datName = getFileName($sf);
                    my $datSize = getFileSize($sf);
                    my@arrStr = split / _ / ,
                    $datName;
                    my $filepath = getcwd."/".$zhangqi."/"."dir.bos_$arrStr[2]_$arrStr[0]$arrStr[1]";
                    my $content = $datName." ".$datSize;
                    create_new($filepath, $content);
                }
            }
        }
    }
    close DIRFILE;
}
sub create_new {
    my($path, $content) = @_;
    open NEW0,
    ">$path";
    print NEW0 $content;
    close NEW0;
}
