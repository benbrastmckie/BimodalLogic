# Fix TEXINPUTS path resolution for standalone subfile compilation
# Compute absolute paths BEFORE loading parent config to avoid cwd() issues

use Cwd qw(abs_path cwd);
use File::Basename;

my $subfiles_dir = cwd();
my $theory_latex_dir = abs_path("$subfiles_dir/..");
my $project_root = abs_path("$subfiles_dir/../../../..");

# Set TEXINPUTS with absolute paths
# This ensures paths are correct regardless of where latexmk is invoked from
$ENV{'TEXINPUTS'} = "$theory_latex_dir/assets//:$theory_latex_dir//:$project_root/latex//:" . ($ENV{'TEXINPUTS'} || '');

# Now load parent config (which may also add paths, but ours take precedence)
do '../latexmkrc';
