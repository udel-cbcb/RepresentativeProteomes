	while($line=<RPG>) {
		if($line =~ /^>/) {
			($upId, $taxId) = (split(/\t/, $line))[0, 1];
			$upId =~ s/^>//;
			$key1 = $upId."-".$taId;
			my $proteome1 = $proteomesHash{$key1};
			my $membersRef1 = $proteome1->getMembers();
			my $taxonomyId = $proteome1->getTaxId();
			my $uniRef50sRef1 = $proteome1->getUniRef50s();
                	my %uniRef50s1 = %$uniRef50sRef1;
                	my $membersRef1 = $proteome1->getMembers();
                	my %members1 = %$membersRef1;
                	my %panMembers= ();
                	my $upIdAndTaxId1 = $proteome1->getUPIdAndTaxId();
                	foreach my $key1 (keys %members1) {
                        	$upIdAndTaxEntryHash{$upIdAndTaxId1}{$upIdAndTaxId1}{$key1} = 1;
                        	$panMembers{$key1} = $upId."\t".$taxId."\t".$entryProteomeHash{$key1}{$upIdAndTaxId1};
                	}
		}
		elsif($line !~ /^$/) {	
			($upId, $taxId) = (split(/\t/, $line))[0, 1];
			$upId =~ s/^\s+//;
			$key2 = $upId."-".$taId;
 			my $proteome2 = $proteomesHash{$key2};
 			my $uniRef50sRef2 = $proteome2->getUniRef50s();
                        my %uniRef50s2 = %$uniRef50sRef2;
                        my $upIdAndTaxId = $proteome2->getUPIdAndTaxId();
                        foreach my $uniRefAc (keys %uniRef50s2) {
                        	if($uniRef50s1{$uniRefAc} eq "") {
                                	my $proteinsRef = $proteomeUniRefEntryHash{$upIdAndTaxId}{$uniRefAc};
                                        my %proteins = %$proteinsRef;
                                        $protein = findTopProtein(\%proteins);
                                        if($protein) {
                                        	$ac = $protein->getAC();
                                                if($panMembers{$ac} eq "") {
                                                	$panMembers{$ac} = $upId."\t".$taxId."\t".$uniRefAc;
                                                        $upIdAndTaxEntryHash{$proteome1->getUPIdAndTaxId()}{$upIdAndTaxId}{$ac} = 1;
                                                        $uniRef50s1{$uniRefAc} = "1";
                                                }
                                        }
                                }
			}
		}
 		$proteome1->setPanMembers(\%panMembers);
	}
	open(PP, ">", "../results_corr_consist/$Xin/pp"."-".$Xin.".txt") or die "Can't open $Xin pp file\n";
        foreach my $k1 (sort keys (%rpgNameHash)) {
                my $key1 = $rpgNameHash{$k1};
                my $proteome1 = $proteomesHash{$key1};
                my $panMembersRef = $proteome1->getPanMembers();
                my %panMembers = %$panMembersRef;
                my $panMemberSize = keys %panMembers;
                if($panMemberSize > 0) {
                        my $genusId1 = $upIdAndTaxIdToGenus{$proteome1->getUPIdAndTaxId()};
                        my $genusName1 = $upIdAndTaxIdToScientificName{$genusId1};

                        $upId = $proteome1->getUPId();
                        $taxonomyId = $proteome1->getTaxId();
                        if($Xin == 95) {
                                print PP ">Pan-Proteome_".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $upIdAndTaxIdScoresHash95{$proteome1->getUPIdAndTaxId()})."(".$pps95{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\n";
                        }
                        else {
                                print PP ">Pan-Proteome_".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $proteome1->getScore())."(".$pps{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\n";
                        }
                        $upIdAndTaxId1 = $proteome1->getUPIdAndTaxId();
                        foreach my $memberTaxId (sort keys %{$upIdAndTaxEntryHash{$upIdAndTaxId1}}) {
                                 my $entriesRef = $upIdAndTaxEntryHash{$upIdAndTaxId1}{$memberTaxId};
                                 my %entries = %$entriesRef;
                                 my $memberCount = keys(%entries);
                                ($upId, $taxonomyId) = (split(/-/, $memberTaxId))[0, 1];
                                 print PP " #".$upId."\t".$taxonomyId."\t".$memberCount."\n";
                        }
                        foreach(sort keys %panMembers) {
                                print PP " ".$_."\t".$panMembers{$_}."\n";
                        }
                        print PP "\n";
                }
        }
        close(PP);
