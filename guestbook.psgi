
use FindBin qw($Bin);
use lib "$Bin/lib";

use GB::Root;

my %opts=(
	root_dir => $Bin,
);
my $gb=GB::Root->new(%opts);
$gb->run;

