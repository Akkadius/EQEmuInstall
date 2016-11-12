#!/usr/bin/perl

use Time::HiRes qw(usleep);

print "\nAkka's Linux Server Launcher\n";

#::: Arguments
# zones="40" = specified x number of zones to launch
# loginserver = Launch loginserver
# no_query_serv - disable running of queryserv
# silent_launcher - does not send server status updates to console
# print_status_once - prints server status once and exits
# kill_server - kills server processes and exits
# no_status_update - Doesn't print a repeated server status update

$kill_server = 0;
$print_status_once = 0;

while($ARGV[$n]){
    print $n . ': ' . $ARGV[$n] . "\n" if $Debug;
	if($ARGV[$n] eq "silent_launcher"){
		$silent_launcher = 1;
	}
	if($ARGV[$n] eq "kill_server"){
		$kill_server = 1;
		print "Shutting server down...\n";
	}
	if($ARGV[$n] eq "no_query_serv"){
		$no_query_serv = 1;
	}
	if($ARGV[$n] eq "loginserver"){
		$use_loginserver = 1;
		print "Loginserver set to run...\n";
	}
	if($ARGV[$n] eq "print_status_once"){
		$print_status_once = 1;
	}
	if($ARGV[$n] eq "no_status_update"){
		$no_status_update = 1;
	}
	if($ARGV[$n]=~/zones=/i){
		my @data = split('=', $ARGV[$n]);
		print "Zones to launch: " . $data[1] . "\n";
		$zones_to_launch = $data[1];
	}
    $n++;
}

if($kill_server == 0 && $print_status_once == 0){ 
	$l_processes = `ps aux`;
	my @processes = split("\n", $l_processes);
	foreach my $val (@processes){
		@data = split(" ", $val);
		if($val=~/server_launcher/i){
			$lc_count++;
		}
	}
	if($lc_count > 1){
		print "Launcher already running... Exiting...\n";
		exit;
	}
}

if(!$print_status_once && $kill_server){
	$l_processes = `ps aux`;
	my @processes = split("\n", $l_processes);
	foreach my $val (@processes){
		@data = split(" ", $val);
		if($val=~/kill_server/i){
			next;
		}
		if($val=~/server_launcher/i){
			$pid = $data[1];
			system("kill " . $pid);
		}
	}
	system("pkill queryserv");
	system("pkill ucs");
	system("pkill eqlaunch");
	system("pkill zone");
	system("pkill world");
	system("pkill shared_memory");
	system("pkill loginserver");
}

if($kill_server){
	print "Server shutdown...\n";
	exit;
}

if(!$zones_to_launch){
	$zones_to_launch = 30;
}

if(!$silent_launcher){
	$silent_launcher = 0;
}

#::: Don't unset this
$start_in_background = 1;

if($start_in_background == 1){
	$background_start = " & ";
	if($silent_launcher){
		$pipe_redirection = " > /dev/null ";
	}
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
	if($silent_launcher || $no_status_update){ 
		return;
	}
	print "									\r";
	print "World: " . $process_status{$world_process_count} . " ";
	print "Zones: (" . $zone_process_count . "/" . $zones_to_launch . ") ";
	print "UCS: " . $process_status{$ucs_process_count} . " ";
	print "Queryserv: " . $process_status{$queryserv_process_count} . " ";
	if($use_loginserver){ 
		print "Loginserver: " . $process_status{$loginserver_process_count} . " "; 
	}
	if($print_status_once){
		print "\n";
	}
	else{
		print "\r";
	}
}

while(1){
	$zone_process_count = 0;
	$world_process_count = 0;
	$queryserv_process_count = 0;
	$ucs_process_count = 0;
	$loginserver_process_count = 0;

	$l_processes = `ps aux`;
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
	
	if(!$print_status_once){
		#::: Loginserver Process
		if($use_loginserver){	
			for($i = $loginserver_process_count; $i < 2; $i++){
				system("./loginserver " . $pipe_redirection . " "  . $background_start); 
				$loginserver_process_count++;
				print_status(); 
			}
		}
		#::: World Process
		for($i = $world_process_count; $i < 1; $i++){ 
			system("./world " . $pipe_redirection . " "  . $background_start); 
			$world_process_count++;
			print_status();
			sleep(1);
		}
		#::: Zone Processes
		for($i = $zone_process_count; $i < $zones_to_launch; $i++){
			if($zone_start_in_background == 1){
				system("start /b zone > nul");
			}
			else{
				system("./zone " . $pipe_redirection . " "  . $background_start);
			}
			$zone_process_count++;
			print_status();
			usleep(100);
		}
		#::: Queryserv Process
		if($no_query_serv != 1){
			for($i = $queryserv_process_count; $i < 1; $i++){ 
				system("./queryserv " . $pipe_redirection . " "  . $background_start); 
				print_status();
			}
		}
		#::: UCS Process
		for($i = $ucs_process_count; $i < 1; $i++){ 
			system("./ucs " . $pipe_redirection . " "  . $background_start); 
			print_status();
		}
	}
	else {
		exit;
	}
	
	sleep(1);
}
