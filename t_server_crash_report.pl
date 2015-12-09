use Config;
if($Config{osname}=~/linux/i){ $OS = "Linux"; }
if($Config{osname}=~/Win|MS/i){ $OS = "Windows"; }

opendir my $dir, "logs/crashes";
my @files = readdir $dir;
closedir $dir;
$inc = 0;
foreach my $val (@files){
	if($val=~/crash_/i){
		$stl = 0;
		$crash[$inc] = "";
		my $file = "logs/crashes/" . $val;
		open my $info, $file or die "Could not open $file: $!"; 
		while( my $line = <$info>)  {
			# print $line;
			if($line=~/CRTStartup/i){ $stl = 0; }
			@data = split('\[Crash\]', $line);
			if($stl == 1){ $crash[$inc] .= $data[1]; }
			if($line=~/dbghelp.dll/i){ $stl = 1; }
		} 
		close $info;
		$inc++;
	}
}

#::: Count Crash Occurrence first
$i = 0;
while($crash[$i]){
	$crash_count[length($crash[$i])]++;
	$unique_crash[length($crash[$i])] = $crash[$i];
	$i++;
}

open (FILE, '> logs/crashes/report_summary.txt');

$i = 0;
while($crash[$i]){
	if($unique_crash_tracker[length($crash[$i])] != 1){
		print "Crash Occurrence " . $crash_count[length($crash[$i])] . " Time(s) Length (" . length($crash[$i]) .  ") \n\n"; 
		print $crash[$i] . "\n";
		print "=========================================\n";
		print FILE "Crash Occurrence " . $crash_count[length($crash[$i])] . " Time(s) Length (" . length($crash[$i]) .  ") \n\n"; 
		print FILE $crash[$i] . "\n";
		print FILE "=========================================\n";
	}
	$unique_crash_tracker[length($crash[$i])] = 1;
	$i++;
}

close (FILE);

$filename = "logs/crashes/report_summary.txt";
if (-e $filename) { 
	if($OS eq "Windows"){
		system("notepad.exe $filename");
	}
}
else{
	print "No crashes found, this is a good thing! Press any key to exit...";
	<>;
}
