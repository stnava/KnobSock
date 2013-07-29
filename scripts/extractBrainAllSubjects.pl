#/usr/bin/perl -w

use strict;

use Cwd 'realpath';
use Switch;
use File::Find;
use File::Basename;
use File::Path;
use File::Spec;
use FindBin qw($Bin);

my $usage = qq{
  Usage: runRegistrations.pl <outputDir>
 };

# my ( $baseDirectory, $outputDirectory ) = @ARGV;
my $baseDirectory = '/home/njt4n/share/Data/Public/MICCAI-2013-SATA-Challenge-Data/diencephalon/';
my $ANTsPath = '/home/njt4n/share/Pkg/ANTs/bin/bin/';

my ( $outputDirectory ) = @ARGV;

if( ! -d $outputDirectory )
  {
  mkpath( $outputDirectory, {verbose => 0, mode => 0755} ) or
    die "Can't create output directory $outputDirectory\n\t";
  }

my $testingDirectory = "${baseDirectory}/testing-images/";
my $trainingDirectory = "${baseDirectory}/training-images/";
my $testingLabelsDirectory = "${baseDirectory}/testing-labels/";
my $trainingLabelsDirectory = "${baseDirectory}/training-labels/";

my @testingImages = <${testingDirectory}/*.nii.gz>;
my @trainingImages = <${trainingDirectory}/*.nii.gz>;
my @testingLabels = <${testingLabelsDirectory}/*.nii.gz>;
my @trainingLabels = <${trainingLabelsDirectory}/*.nii.gz>;

my @images = ( @testingImages, @trainingImages );

my $templateDir = '/home/njt4n/share/Data/Public/MICCAI-2012-Multi-Atlas-Challenge-Data/template';
my $template = "${templateDir}/T_template0.nii.gz";
my $templateProbabilityMask = "${templateDir}/T_template0_BrainCerebellumProbabilityMask.nii.gz";
my $templateExtractionMask = "${templateDir}/T_template0_BrainCerebellumRegistrationMask.nii.gz";

my $count = 0;
for( my $i = 0; $i < @images; $i++ )
  {
  my ( $imagePrefix, $directories, $suffix ) = fileparse( $images[$i], ".nii.gz" );

  my $outputPrefix = "${outputDirectory}/${imagePrefix}";

  my $commandFile = "${outputPrefix}command.sh";

  open( FILE, ">${commandFile}" );
  print FILE "#!/bin/sh\n";
  print FILE "export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1\n";
  print FILE "\n";

  my @args = ( 'sh', "${ANTsPath}/antsBrainExtraction.sh",
                     '-d', 3,
                     '-a', $images[$i],
                     '-e', $template,
                     '-m', $templateProbabilityMask,
                     '-f', $templateExtractionMask,
                     '-k', 0,
                     '-o', $outputPrefix );
#   system( @args ) == 0 || die "DIED:  $outputPrefix\n";

  print FILE "@args\n\n";
  close( FILE );

  if( ! -e "${outputPrefix}BrainExtractionBrain.nii.gz" )
    {
    print "** registration ${outputPrefix}\n";
    $count++;
#       if( $count % 2 == 0 )
#         {
      system( "qsub -N ${count}_ch -q standard -l nodes=1:ppn=1 -l walltime=20:00:00 -l mem=12gb $commandFile" );
#         }
#       else
#         {
#         system( "qsub -N ${count}_bsyn -q nopreempt -l nodes=1:ppn=1 -l walltime=80:00:00 -l mem=12gb $commandFile" );
#         }
    }
  else
    {
    print " not doing ${outputPrefix}\n";
    }
#    sleep 1;
#    }
  }

print "Running $count command files.\n";
