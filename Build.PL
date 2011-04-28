
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Module::Build' => '0.3601'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Subroutine metadata & wrapping framework',
  'dist_author' => [
    'Steven Haryanto <stevenharyanto@gmail.com>'
  ],
  'dist_name' => 'Sub-Spec',
  'dist_version' => '0.13',
  'license' => 'perl',
  'module_name' => 'Sub::Spec',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'File::Which' => '0',
    'Log::Any' => '0',
    'Probe::Perl' => '0',
    'Test::More' => '0.96',
    'perl' => '5.010000'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
