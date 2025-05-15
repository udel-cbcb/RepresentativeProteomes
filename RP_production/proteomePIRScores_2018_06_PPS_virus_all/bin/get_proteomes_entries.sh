for a in ../data/score/*_score.txt ; do cat $a | grep -v "^Accession" | awk '{print $1}' | sort -u >> ../data/score/proteome_entries.txt; done
