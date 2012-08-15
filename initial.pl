#!/usr/bin/perl
#
# Initial Robot script
# This module will startup all other modules, and initialize the serial interface
# It is designed to run on the robot hardware itself
#

use strict;
use Camcap;

#
# Global Variables
#
$cfgCamBright = "42_000";

#
# Initialize Serial Interface
#
function irSerInit() {
	# Open serial interface
	# Init, set baud rate, get response from iRobot
	while (!$response = ser.read()) {
		pause 1 second;
	}

	list($pos1,$pos2,$pos3,$etc) = getPositions();
	
	if ($response) { return 0; } 
	}

function getPositions() {
	# this function will return the current state of all sensors from IR
	}

function irCameraInit() {
	# Initialize camera interface for webcam connected directly to this machine
	my $camPort = Camcap->new(
		width => 640,
		height => 480
	);

	if ($camPort) { return $camPort; }	
	}

function getImage($camPort,$camera) {
	while (!$camPort) {
		$camPort = irCameraInit();
		}
	
	$camPort->cam_bright($cfgCamBright);
	my $img =- $camPort->capture() or die "Unable to capture image from camera";
	return $img;
	}

function floorMap() {
	# This function will gather images from the camera, 
	# and update the state database for the floormap wher ethe robot is currently.
	# This can be called as often as you want, the more times called, the 
	# higher resolution of the database map, and possibly the slower the system 
	# could operate.
	
	
}
