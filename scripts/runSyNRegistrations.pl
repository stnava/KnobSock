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

my $template = '/home/njt4n/share/Data/Public/MICCAI-2012-Multi-Atlas-Challenge-Data/template/T_template0_BrainCerebellum.nii.gz';

@trainingImages = ( @trainingImages, @testingImages );
@trainingLabels = ( @trainingLabels, @testingLabels );

my @suffixList = ( ".nii.gz" );

my $count = 0;
for( my $i = 0; $i < @trainingImages; $i++ )
  {
  my ( $trainingImagePrefix, $trainingDirectories, $trainingSuffix ) = fileparse( $trainingImages[$i], @suffixList );

  my $brainImage = "${outputDirectory}/${trainingImagePrefix}BrainExtractionBrain.nii.gz";

#  for( my $j = 0; $j < @trainingImages; $j++ )
#    {
#    my ( $trainingImagePrefix, $trainingDirectories, $trainingSuffix ) = fileparse( $trainingImages[$j], @suffixList );
#
#    if( $testingImagePrefix =~ m/$trainingImagePrefix/ )
#      {
#      next;
#      }

    my $outputPrefix = "${outputDirectory}/T_template0x${trainingImagePrefix}";

    my $commandFile = "${outputPrefix}command.sh";

    open( FILE, ">${commandFile}" );
    print FILE "#!/bin/sh\n";
    print FILE "export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1\n";
    print FILE "\n";

    my @regArgs = ( "${ANTsPath}/antsRegistration",
                   '-d', 3,
                   '-o', "${outputPrefix}",
                   '-u', 1,
                   '-w', '[0.01,0.99]',
                   '-r', "[${template},${brainImage},1]",             # align centers of mass
                   '-t', 'Rigid[0.1]',                                                   # rigid stage
                   '-m', "MI[${template},${brainImage},1,32,Regular,0.25]",
                   '-c', '[1000x500x250x100,1e-8,10]',
                   '-s', '4x2x1x0',
                   '-f', '8x4x2x1',
                   '-t', 'Affine[0.1]',                                                  # affine stage
                   '-m', "MI[${template},${brainImage},1,32,Regular,0.25]",
                   '-c', '[1000x500x250x100,1e-8,10]',
                   '-s', '4x2x1x0',
                   '-f', '8x4x2x1',
                   '-t', 'SyN[0.1,3,0]',                             # syn stage
                   '-m', "CC[${template},${brainImage},1,4]",
                   '-c', '[100x100x70x20,1e-9,15]',
                   '-s', '3x2x1x0',
                   '-f', '6x4x2x1'
                );
    print FILE "@regArgs\n\n";

    my @xfrmArgs = ( "${ANTsPath}/antsApplyTransforms",
                   '-d', 3,
                   '-i', $trainingImages[$i],
                   '-r', $template,
                   '-o', "${outputPrefix}Warped.nii.gz",
                   '-n', 'BSpline',
                   '-t', "${outputPrefix}1Warp.nii.gz",
                   '-t', "${outputPrefix}0GenericAffine.mat"
                   );
    print FILE "@xfrmArgs\n\n";

#    print FILE "rm -f ${outputPrefix}1Warp.nii.gz ${outputPrefix}1InverseWarp.nii.gz ${outputPrefix}0MatrixOffset.mat\n";

    close( FILE );

    if( ! -e "${outputPrefix}1Warp.nii.gz" )
      {
      print "** registration ${outputPrefix}\n";
      $count++;
#       if( $count % 2 == 0 )
#         {
        system( "qsub -N ${count}_syn -q standard -l nodes=1:ppn=1 -l walltime=20:20:00 -l mem=12gb $commandFile" );
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
