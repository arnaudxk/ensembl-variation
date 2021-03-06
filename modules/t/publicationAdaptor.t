# Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


use strict;
use warnings;
use Test::More;



use Bio::EnsEMBL::Test::TestUtils;
use Bio::EnsEMBL::Test::MultiTestDB;


our $verbose = 0;

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new('homo_sapiens');

my $vdb = $multi->get_DBAdaptor('variation');

my $va = $vdb->get_VariationAdaptor();
my $pa = $vdb->get_PublicationAdaptor();

ok($pa && $pa->isa('Bio::EnsEMBL::Variation::DBSQL::PublicationAdaptor'), "isa publication adaptor");

# test fetch by PMID

my $pub = $pa->fetch_by_pmid('22779046');


ok($pub->pmid() eq '22779046',       'PMID by PMID');
ok($pub->pmcid() eq 'PMC3392070',   'PMCID by PMID'  );
ok($pub->year() eq '2012',          'year by PMID');
ok($pub->title() eq 'Coanalysis of GWAS with eQTLs reveals disease-tissue associations.',    'title by PMID');
ok($pub->authors() eq 'Kang HP, Morgan AA, Chen R, Schadt EE, Butte AJ.',     'authors by PMID');


my $pub2 = $pa->fetch_by_pmcid('PMC3392070',);
ok($pub2->pmid() eq '22779046',       'PMID by PMCID');

my $pub3 = $pa->fetch_by_dbID(36249);
ok($pub3->pmid() eq '22779046',       'PMID by dbID');




my $var = $va->fetch_by_name("rs7698608");
my $pubs = $pa->fetch_all_by_Variation($var);
ok($pubs->[0]->pmid() eq '22779046',     'PMID by variation');
ok($pubs->[0]->pmcid() eq 'PMC3392070',   'PMCID by variation'  );



done_testing();
