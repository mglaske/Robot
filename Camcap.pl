############################# 
package Camcap; 
############################# 

use strict;
use warnings;
use Video::Capture::V4l;
use Imager;
use Imager::Misc;
use Log::Log4perl qw(:easy);

############################# 
sub new { 
#############################
	my ($class, @options) = @_;
	my $self = {
		width => 320, 
		height => 240, 
		avg_opt => 128, 
		avg_acc => 20, 
		br_min => 0,
		br_max => 65535, 
		@options,
		};
	$self->{video} = Video::Capture::V4l->new() or LOGDIE "Open video failed: $!";
	bless $self, $class; 
}

############################# 
sub cam_bright { 
#############################
	my ($self, $brightness) = @_;
	my $pic = $self->{video}->picture();
	$pic->brightness($brightness);
	$pic->set(); 
}

############################# 
sub img_avg { 
#############################
	my ($img) = @_; 
	my $br = Imager::Misc::brightness($img);
	DEBUG "Brightness: $br";
	return $br;
}

############################
sub calibrate {
############################
	my ($self) = $_;
	
	DEBUG "Calibrating";
	
	return if img_avg( $self->capture( $self->{br_min} ) ) > $self->{avg_opt};
	return if img_avg( $self->capture( $self->{br_max} ) ) < $self->{avg_opt};
	
	# Start binary search
	my ($low, $high) = ( $self->{br_min}, $self->{br_max} );

	for (
		my $max = 5;
		$low <= $high && $max;
		$max--
		)
	my $try = int(($low+$high) / 2);
	my $i = $self->capture($try);
	my $br = img_avg($i);

	DEBUG "br=$try got avg=$br";

	return if abs( $br - $self->{avg_opt} ) <= $self->{avg_acc};

	if ($br < $self->{avg_opt}) { $low = $try + 1; } else { $high = $try - 1; }
}

############################
sub capture { 
############################
	my ($self, $br) = @_;

	$self->cam_bright($br)
		if defined $br;

	my $frame;

	for my $frameno(0,1) {
		$frame = $self->{video}->capture(
			$frameno,
			$self->{width},
			$self->{height} );

		$self->{video}->sync($frameno) or LOGDIE "Unable to sync";
	}

	my $i = Imager->new();
	$frame = reverse $frame;
	$i->read(
		type => "pnm",
		data => "P6\n$self->{width} $self->{height}\n255\n".$frame
		);
	$i->flip(dir => "hv");
}

1;
