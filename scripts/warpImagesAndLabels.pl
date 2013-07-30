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
my $baseDirectory = '/Users/ntustison/Data/Public/MICCAI-2013-SATA-Challenge-Data/diencephalon/';
my $ANTsPath = '/Users/ntustison/Pkg/ANTs/bin/bin/';

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

my @testingAffines = <${baseDirectory}/../Processed/diencephalon/SyN/*0GenericAffine.mat>;
my @testingWarps = <${baseDirectory}/../Processed/diencephalon/SyN/*1Warp.nii.gz>;
my @testingInverseWarps = <${baseDirectory}/../Processed/diencephalon/SyN/*1InverseWarp.nii.gz>;

my @bothImages = ( @trainingImages, @testingImages );
my @bothLabels = ( @trainingLabels, @testingLabels );

my $template = '/home/njt4n/share/Data/Public/MICCAI-2012-Multi-Atlas-Challenge-Data/template/T_template0.nii.gz';

my @suffixList = ( ".nii.gz" );

for( my $i = 0; $i < @trainingImages; $i++ )
  {
  my ( $trainingImagePrefix, $trainingDirectories, $trainingSuffix ) = fileparse( $trainingImages[$i], @suffixList );

  for( my $j = 0; $j < @bothImages; $j++ )
   {
   my ( $bothImagePrefix, $bothDirectories, $bothSuffix ) = fileparse( $bothImages[$j], @suffixList );
#
   if( $trainingImagePrefix =~ m/$bothImagePrefix/ )
     {
     next;
     }

    my $outputPrefix = "${outputDirectory}/${bothImagePrefix}x${trainingImagePrefix}";

    my $trainingAffine = "${baseDirectory}/../Processed/diencephalon/SyN/T_template0x${trainingImagePrefix}0GenericAffine.mat";
    my $trainingWarp = "${baseDirectory}/../Processed/diencephalon/SyN/T_template0x${trainingImagePrefix}1Warp.nii.gz";
    my $bothAffine = "${baseDirectory}/../Processed/diencephalon/SyN/T_template0x${bothImagePrefix}0GenericAffine.mat";
    my $bothInverseWarp = "${baseDirectory}/../Processed/diencephalon/SyN/T_template0x${bothImagePrefix}1InverseWarp.nii.gz";

    my @xfrmArgs = ( "${ANTsPath}/antsApplyTransforms",
                   '-d', 3,
                   '-i', $trainingImages[$i],
                   '-r', $bothImages[$j],
                   '-o', "${outputPrefix}Warped.nii.gz",
                   '-n', 'Linear',
                   '-t', "[${bothAffine},1]",
                   '-t', $bothInverseWarp,
                   '-t', $trainingWarp,
                   '-t', $trainingAffine
                   );

#     my @xfrmArgs = ( "${ANTsPath}/antsApplyTransforms",
#                    '-d', 3,
#                    '-i', $trainingLabels[$i],
#                    '-r', $bothImages[$j],
#                    '-o', "${outputPrefix}LabelsWarped.nii.gz",
#                    '-n', 'NearestNeighbor',
#                    '-t', "[${bothAffine},1]",
#                    '-t', $bothInverseWarp,
#                    '-t', $trainingWarp,
#                    '-t', $trainingAffine
#                    );

    system( @xfrmArgs ) == 0 || die "apply xform.\n";
    }
  }

