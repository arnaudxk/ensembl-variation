# Ensembl module for Bio::EnsEMBL::Variation::VariationFeature
#
# Copyright (c) 2004 Ensembl
#


=head1 NAME

Bio::EnsEMBL::Variation::VariationFeature - A genomic position for a nucleotide variation.

=head1 SYNOPSIS

    # Variation feature representing a single nucleotide polymorphism
    $vf = Bio::EnsEMBL::Variation::VariationFeature->new
       (-start   => 100,
        -end     => 100,
        -strand  => 1,
        -slice   => $slice,
        -allele_string => 'A/T',
        -variation_name => 'rs635421',
        -map_weight  => 1,
        -variation => $v);

    # Variation feature representing a 2bp insertion
    $vf = Bio::EnsEMBL::Variation::VariationFeature->new
       (-start   => 1522,
        -end     => 1521, # end = start-1 for insert
        -strand  => -1,
        -slice   => $slice,
        -allele_string => '-/AA',
        -variation_name => 'rs12111',
        -map_weight  => 1,
        -variation => $v2);

    ...

    # a variation feature is like any other ensembl feature, can be
    # transformed etc.
    $vf = $vf->transform('supercontig');

    print $vf->start(), "-", $vf->end(), '(', $vf->strand(), ')', "\n";

    print $vf->name(), ":", $vf->allele_string();

    # Get the Variation object which this feature represents the genomic
    # position of. If not already retrieved from the DB, this will be
    # transparently lazy-loaded
    my $v = $vf->variation();

=head1 DESCRIPTION

This is a class representing the genomic position of a nucleotide variation
from the ensembl-variation database.  The actual variation information is
represented by an associated Bio::EnsEMBL::Variation::Variation object. Some
of the information has been denormalized and is available on the feature for
speed purposes.  A VariationFeature behaves as any other Ensembl feature.
See B<Bio::EnsEMBL::Feature> and B<Bio::EnsEMBL::Variation::Variation>.

=head1 CONTACT

Post questions to the Ensembl development list: ensembl-dev@ebi.ac.uk

=head1 METHODS

=cut

use strict;
use warnings;

package Bio::EnsEMBL::Variation::VariationFeature;

use Bio::EnsEMBL::Feature;
use Bio::EnsEMBL::Utils::Exception qw(throw warning);
use Bio::EnsEMBL::Utils::Argument  qw(rearrange);

our @ISA = ('Bio::EnsEMBL::Feature');

#contains a hash with the highest to the lowest possible consequence type in a trasncript
our %CONSEQUENCE_TYPES = ('INTRONIC' => 6,
			  'UPSTREAM' => 7,
			  'DOWNSTREAM' => 8,
			  'SYNONYMOUS_CODING' => 3,
			  'NON_SYNONYMOUS_CODING', => 2,
			  'FRAMESHIFT_CODING' => 1,
			  '5PRIME_UTR' => 4,
			  '3PRIME_UTR' => 5,
			  'INTERGENIC' => 9);

=head2 new

  Arg [-dbID] :
    see superclass constructor

  Arg [-ADAPTOR] :
    see superclass constructor

  Arg [-START] :
    see superclass constructor
  Arg [-END] :
    see superclass constructor

  Arg [-STRAND] :
    see superclass constructor

  Arg [-SLICE] :
    see superclass constructor

  Arg [-VARIATION_NAME] :
    string - the name of the variation this feature is for (denormalisation
    from Variation object).

  Arg [-MAP_WEIGHT] :
    int - the number of times that the variation associated with this feature
    has hit the genome. If this was the only feature associated with this
    variation_feature the map_weight would be 1.

  Arg [-VARIATION] :
    int - the variation object associated with this feature.

  Arg [-VARIATION_ID] :
    int - the internal id of the variation object associated with this
    identifier. This may be provided instead of a variation object so that
    the variation may be lazy-loaded from the database on demand.

  Example    :
    $vf = Bio::EnsEMBL::Variation::VariationFeature->new
       (-start   => 100,
        -end     => 100,
        -strand  => 1,
        -slice   => $slice,
        -allele_string => 'A/T',
        -variation_name => 'rs635421',
        -map_weight  => 1,
        -variation => $v);

  Description: Constructor. Instantiates a new VariationFeature object.
  Returntype : Bio::EnsEMBL::Variation::Variation
  Exceptions : none
  Caller     : general

=cut

sub new {
  my $caller = shift;
  my $class = ref($caller) || $caller;

  my $self = $class->SUPER::new(@_);
  my ($allele_str, $var_name, $map_weight, $variation, $variation_id) =
    rearrange([qw(ALLELE_STRING VARIATION_NAME 
                  MAP_WEIGHT VARIATION VARIATION_ID)], @_);

  $self->{'allele_string'}  = $allele_str;
  $self->{'variation_name'} = $var_name;
  $self->{'map_weight'}     = $map_weight;
  $self->{'variation'}      = $variation;
  $self->{'_variation_id'}  = $variation_id;

  return $self;
}



sub new_fast {
  my $class = shift;
  my $hashref = shift;
  return bless $hashref, $class;
}


=head2 allele_string

  Arg [1]    : string $newval (optional)
               The new value to set the allele_string attribute to
  Example    : $allele_string = $obj->allele_string()
  Description: Getter/Setter for the allele_string attribute.
               The allele_string is a '/' demimited string representing the
               alleles associated with this features variation.
  Returntype : string
  Exceptions : none
  Caller     : general

=cut

sub allele_string{
  my $self = shift;
  return $self->{'allele_string'} = shift if(@_);
  return $self->{'allele_string'};
}



=head2 display_id

  Arg [1]    : none
  Example    : print $vf->display_id(), "\n";
  Description: Returns the 'display' identifier for this feature. For
               VariationFeatures this is simply the name of the variation
               it is associated with.
  Returntype : string
  Exceptions : none
  Caller     : webcode

=cut

sub display_id {
  my $self = shift;
  return $self->{'variation_name'} || '';
}



=head2 variation_name

  Arg [1]    : string $newval (optional)
               The new value to set the variation_name attribute to
  Example    : $variation_name = $obj->variation_name()
  Description: Getter/Setter for the variation_name attribute.  This is the
               name of the variation associated with this feature.
  Returntype : string
  Exceptions : none
  Caller     : general

=cut

sub variation_name{
  my $self = shift;
  return $self->{'variation_name'} = shift if(@_);
  return $self->{'variation_name'};
}



=head2 map_weight

  Arg [1]    : int $newval (optional) 
               The new value to set the map_weight attribute to
  Example    : $map_weight = $obj->map_weight()
  Description: Getter/Setter for the map_weight attribute. The map_weight
               is the number of times this features variation was mapped to
               the genome.
  Returntype : int
  Exceptions : none
  Caller     : general

=cut

sub map_weight{
  my $self = shift;
  return $self->{'map_weight'} = shift if(@_);
  return $self->{'map_weight'};
}


=head2 get_all_TranscriptVariations

  Example     : $vf->get_all_TranscriptVariations;
  Description : Getter a list with all the TranscriptVariations associated associated to the VariationFeature
  Returntype  : ref to Bio::EnsEMBL::Variation::VariationFeature
  Exceptions  : None
  Caller      : general

=cut

sub get_all_TranscriptVariations{
    my $self = shift;

    return $self->{'transcriptVariations'};
}

=head2

   Arg [1]     : Bio::EnsEMBL::Variation::TranscriptVariation
   Example     : $vf->add_TranscriptVariation($tv);
   Description : Adds another Transcript variation to the variation feature object
   Exceptions  : thrown on bad argument
   Caller      : Bio::EnsEMBL::Variation::TranscriptVariationAdaptor

=cut

sub add_TranscriptVariation{
    my $self= shift;
    if (@_){
	if(!ref($_[0]) || !$_[0]->isa('Bio::EnsEMBL::Variation::TranscriptVariation')) {
	    throw("Bio::EnsEMBL::Variation::TranscriptVariation argument expected");
	}
	#a variation feature can have multiple transcript Variations
	push @{$self->{'transcriptVariations'}},shift;
    }
}


=head2 variation

  Arg [1]    : (optional) Bio::EnsEMBL::Variation::Variation $variation
  Example    : $v = $vf->variation();
  Description: Getter/Setter for the variation associated with this feature.
               If not set, and this VariationFeature has an associated adaptor
               an attempt will be made to lazy-load the variation from the
               database.
  Returntype : Bio::EnsEMBL::Variation::Variation
  Exceptions : throw on incorrect argument
  Caller     : general

=cut

sub variation {
  my $self = shift;

  if(@_) {
    if(!ref($_[0]) || !$_[0]->isa('Bio::EnsEMBL::Variation::Variation')) {
      throw("Bio::EnsEMBL::Variation::Variation argument expected");
    }
    $self->{'variation'} = shift;
  }
  elsif(!defined($self->{'variation'}) && $self->{'adaptor'} &&
        defined($self->{'_variation_id'})) {
    # lazy-load from database on demand
    my $va = $self->{'adaptor'}->db()->get_VariationAdaptor();
    $self->{'variation'} = $va->fetch_by_dbID($self->{'_variation_id'});
  }

  return $self->{'variation'};
}

=head2 consequence_type
   Arg[1]      : (optional) Bio::EnsEMBL::Gene $g
   Example     : if($vf->consequence_type eq 'INTRONIC'){do_something();}
   Description : Getter for the consequence type of this variation, which is the highest of the transcripts that has.
                 If an argument provided, gets the highest of the transcripts where the gene appears
                 Allowed values are: 'INTRONIC','UPSTREAM','DOWNSTREAM',
               'SYNONYMOUS_CODING','NON_SYNONYMOUS_CODING','FRAMESHIFT_CODING',
               '5PRIME_UTR','3PRIME_UTR','INTERGENIC'
   Returntype : string
   Exceptions : throw if provided argument not a gene
   Caller     : general

=cut

sub consequence_type{
    my $self = shift;
    my $highest_priority;
    #first, get all the transcripts, if any
    my $transcript_variations = $self->get_all_TranscriptVariations();
    #if no transcripts, return INTERGENIC type
    if (!defined $transcript_variations){
	return 'INTERGENIC';
    }
    #if an argument is provided, get the highest priority for the transcripts presents in the list
    if (@_){
	my $gene = shift;
	if (!ref $gene || !$gene->isa("Bio::EnsEMBL::Gene")){
	    throw("$gene is not a Bio::EnsEMBL::Gene type!");
	}
	my $transcripts = $gene->get_all_Transcripts();
	my %transcripts_genes;
	my @new_transcripts;
	map {$transcripts_genes{$_->dbID()}++} @{$transcripts};
	foreach my $transcript_variation (@{$transcript_variations}){
	    if (exists $transcripts_genes{$transcript_variation->transcript->dbID()}){
		push @new_transcripts,$transcript_variation;
	    }
	}
	$highest_priority = $self->_highest_priority(\@new_transcripts);
    }
    #no argument provided, get the highest priority in the transcript_variation
    else{
	$highest_priority = $self->_highest_priority($transcript_variations);
    }
    return $highest_priority;
}

#for a list of transcript variations, gets the one with highest priority
sub _highest_priority{
    my $self= shift;
    my $transcript_variations = shift;
    my $highest_type = 'INTERGENIC';
    foreach my $tv (@{$transcript_variations}){
	#with a frameshift coding, return, is the highest value
	if ($tv->consequence_type eq 'FRAMESHIFT_CODING') {
	    return 'FRAMESHIFT_CODING';
	}
	else{
	    if ($CONSEQUENCE_TYPES{$tv->consequence_type} < $CONSEQUENCE_TYPES{$highest_type}){
		$highest_type = $tv->consequence_type;
	    }
	}
    }    
    return $highest_type;
}
1;
