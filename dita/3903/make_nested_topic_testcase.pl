#!/usr/bin/perl
use warnings;
use strict;
use File::Path;

# clean up old files, make new directory
unlink('map.ditamap', 'topic.dita');

# write beginnings of map and topic files
open(my $MAP, ">map.ditamap") or die "can't open 'map.ditamap' for write: $!";
print $MAP <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="urn:oasis:names:tc:dita:rng:bookmap.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>
<map>
  <title>Test Map - @ARGV</title>
  <ditavalref href="filter-A.ditaval"/>
  <topicref href="topic.dita">
EOS

open(my $TOPIC, ">topic.dita") or die "can't open 'topic.ditamap' for write: $!";
print $TOPIC <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="urn:oasis:names:tc:dita:rng:topic.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>
<topic id="root_topic_id">
  <title>Test Topic - @ARGV</title>
EOS

# recursive subroutine to print map entries and write topic files
sub process_next_level {
 my ($depth, $prev_prefix, $this_count, @remaining_counts) = @_;
 my $indent = '  ' x $depth;
 foreach my $i (1 .. $this_count) {
  my $this_id = ${prev_prefix}.${i};

  print $TOPIC $indent."<topic id=\"id_${this_id}\">\n";
  print $TOPIC $indent."  <title>Topic - ${this_id}</title>\n";
  print $TOPIC $indent."  <body>\n";
  print $TOPIC $indent."    <p product=\"A\">This is some text for product A.</p>\n";
  print $TOPIC $indent."    <p product=\"B\">This is some text for product B.</p>\n";
  print $TOPIC $indent."  </body>\n";

  if (@remaining_counts) {
    print $MAP $indent."  <topicref href=\"topic.dita#id_${this_id}\">\n";
    process_next_level($depth+1, "${this_id}_", @remaining_counts);
    print $MAP $indent."  </topicref>\n";
  } else {
    print $MAP $indent."  <topicref href=\"topic.dita#id_${this_id}\"/>\n";
  }

  print $TOPIC $indent."</topic>\n";
 }
}

# call it with the command-line arguments
process_next_level(1, '', @ARGV);

# write end of map
print $MAP "  </topicref>\n";
print $MAP "</map>\n";
close $MAP;

print $TOPIC "</topic>\n";
close $TOPIC;

