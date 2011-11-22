package Bio::EnsEMBL::Variation::StructuralVariationOverlap;

use strict;
use warnings;

use Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele;

use Bio::EnsEMBL::Utils::Scalar qw(assert_ref);
use Bio::EnsEMBL::Utils::Exception qw(throw warning);
use Bio::EnsEMBL::Utils::Argument qw(rearrange);

use base qw(Bio::EnsEMBL::Variation::BaseVariationFeatureOverlap);

sub new {

    my $class = shift;
    
    my %args = @_;

    # swap a '-structural_variation_feature' argument for a '-base_variation_feature' one for the superclass

    for my $arg (keys %args) {
        if (lc($arg) eq '-structural_variation') {
            $args{'-base_variation_feature'} = delete $args{$arg};
        }
    }

    # call the superclass constructor
    my $self = $class->SUPER::new(%args) || return undef;

    return $self;
}

sub new_fast {
    my ($class, $hashref) = @_;
    
    # swap a 'structural_variation_feature' argument for a 'base_variation_feature' one for the superclass
    
    if ($hashref->{structural_variation}) {
        $hashref->{base_variation_feature} = delete $hashref->{structural_variation};
    }
    
    # and call the superclass

    my $self = $class->SUPER::new_fast($hashref);

    my $allele = Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele->new_fast({
        structural_variation_overlap    => $self,
    });

    die unless $allele->base_variation_feature_overlap;

    $self->add_StructuralVariationOverlapAllele($allele);

    return $self;
}

sub structural_variation_feature {
    my $self = shift;
    return $self->base_variation_feature(@_);
}

=head2 add_StructuralVariationOverlapAllele

  Arg [1]    : A Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele instance
  Description: Add an allele to this StructuralVariationOverlap
  Returntype : none
  Exceptions : throws if the argument is not the expected type
  Status     : At Risk

=cut

sub add_StructuralVariationOverlapAllele {
    my ($self, $svoa) = @_;
    assert_ref($svoa, 'Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele');
    return $self->SUPER::add_BaseVariationFeatureOverlapAllele($svoa);
}

=head2 get_reference_StructuralVariationOverlapAllele

  Description: Get the object representing the reference allele of this StructuralVariationOverlap
  Returntype : Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele instance
  Exceptions : none
  Status     : At Risk

=cut

sub get_reference_StructuralVariationOverlapAllele {
    my $self = shift;
    return $self->SUPER::get_reference_BaseVariationFeatureOverlapAllele(@_);
}

=head2 get_all_alternate_StructuralVariationOverlapAlleles

  Description: Get a list of the alternate alleles of this StructuralVariationOverlap
  Returntype : listref of Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele objects
  Exceptions : none
  Status     : At Risk

=cut

sub get_all_alternate_StructuralVariationOverlapAlleles {
    my $self = shift;
    return $self->SUPER::get_all_alternate_BaseVariationFeatureOverlapAlleles(@_);
}

=head2 get_all_StructuralVariationOverlapAlleles

  Description: Get a list of the all the alleles, both reference and alternate, of 
               this StructuralVariationOverlap
  Returntype : listref of Bio::EnsEMBL::Variation::StructuralVariationOverlapAllele objects
  Exceptions : none
  Status     : At Risk

=cut

sub get_all_StructuralVariationOverlapAlleles {
    my $self = shift;
    return $self->SUPER::get_all_BaseVariationFeatureOverlapAlleles(@_);
}

1;
