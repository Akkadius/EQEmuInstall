use Time::HiRes qw(usleep);

print "Akka's Windows Server Launcher\n";

#::: Arguments
# zone_background_start = Starts zone processes in the background
# background_start = Starts all processes in the background
# zones="40" = specified x number of zones to launch
# loginserver = Launch loginserver
# kill_all_on_start = Kills any running processes on start
# no_query_serv - disable running of queryserv

while($ARGV[$n]){
    print $n . ': ' . $ARGV[$n] . "\n" if $Debug;
    if($ARGV[$n] eq "kill_all_on_start"){
		$kill_all_on_start = 1;
	}
    if($ARGV[$n] eq "no_query_serv"){
		$no_query_serv = 1;
	}
    if($ARGV[$n] eq "loginserver"){
		$use_loginserver = 1;
		print "Loginserver set to run...\n";
	}
    if($ARGV[$n] eq "zone_background_start"){
		$zone_start_in_background = 1;
		print "Zone background starting enabled...\n";
	}
    if($ARGV[$n] eq "background_start"){
		$start_in_background = 1;
		print "All process background starting enabled...\n";
	}
    if($ARGV[$n]=~/zones=/i){
        my @data = split('=', $ARGV[$n]);
        print "Zones to launch: " . $data[1] . "\n";
		$zones_to_launch = $data[1];
    }
    $n++;
}

if($kill_all_on_start){
	system("start taskkill /IM queryserv.exe /F > nul");
	system("start taskkill /IM ucs.exe /F > nul");
	system("start taskkill /IM eqlaunch.exe /F > nul");
	system("start taskkill /IM zone.exe /F > nul");
	system("start taskkill /IM world.exe /F > nul");
	system("start taskkill /IM shared_memory.exe /F > nul");
	system("start taskkill /IM loginserver.exe /F > nul");
}

if(!$zones_to_launch){
	$zones_to_launch = 10;
}
if(!$start_in_background){
	$start_in_background = 0;
}

if($start_in_background == 1){
	$background_start = " /b ";
	$pipe_redirection = " > nul ";
}
else{
	$background_start = "";
	$pipe_redirection = "";
}

%process_status = (
	0 => "DOWN",
	1 => "UP",
);

sub print_status{
	print "									\r";
	print "World: " . $process_status{$world_process_count} . " ";
	print "Zones: (" . $zone_process_count . "/" . $zones_to_launch . ") ";
	print "UCS: " . $process_status{$ucs_process_count} . " ";
	print "Queryserv: " . $process_status{$queryserv_process_count} . " ";
	if($use_loginserver){ print "Loginserver: " . $process_status{$loginserver_process_count} . " "; }
	print "\r";
}

while(1){
	$zone_process_count = 0;
	$world_process_count = 0;
	$queryserv_process_count = 0;
	$ucs_process_count = 0;
	$loginserver_process_count = 0;

	$l_processes = `TASKLIST`;
	my @processes = split("\n", $l_processes);
	foreach my $val (@processes){
		if($val=~/ucs/i){
			$ucs_process_count++;
		}
		if($val=~/world/i){
			$world_process_count++;
		}
		if($val=~/zone/i){
			$zone_process_count++;
		}
		if($val=~/queryserv/i){
			$queryserv_process_count++;
		}
		if($val=~/loginserver/i){
			$loginserver_process_count++;
		}
	}
	
	print_status();
	
	#::: Loginserver Process
	if($use_loginserver){	
		for($i = $loginserver_process_count; $i < 1; $i++){ 
			system("start " . $background_start . " loginserver.exe " . $pipe_redirection); 
			$loginserver_process_count++;
			print_status(); 
		}
	}
	#::: World Process
	for($i = $world_process_count; $i < 1; $i++){ 
		system("start " . $background_start . " world.exe " . $pipe_redirection); 
		$world_process_count++;
		print_status();
		sleep(1);
	}
	#::: Zone Processes
	for($i = $zone_process_count; $i < $zones_to_launch; $i++){
		if($zone_start_in_background == 1){
			system("start /b zone.exe > nul");
		}
		else{
			system("start " . $background_start . " zone.exe " . $pipe_redirection);
		}
		$zone_process_count++;
		print_status();
		usleep(100);
	}
	#::: Queryserv Process
	if($no_query_serv != 1){
		for($i = $queryserv_process_count; $i < 1; $i++){ 
			system("start " . $background_start . " queryserv.exe " . $pipe_redirection); 
			print_status();
		}
	}
	#::: UCS Process
	for($i = $ucs_process_count; $i < 1; $i++){ 
		system("start " . $background_start . " ucs.exe " . $pipe_redirection); 
		print_status();
	}
	
	
	sleep(1);
}
