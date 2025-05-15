echo "Total UP"
grep -v "^$" ../results_corr_consist/95/rpg-95.txt | wc -l | awk '{print "95\t"$1}'
grep -v "^$" ../results_corr_consist/75/rpg-75.txt | wc -l | awk '{print "75\t"$1}'
grep -v "^$" ../results_corr_consist/55/rpg-55.txt | wc -l | awk '{print "55\t"$1}'
grep -v "^$" ../results_corr_consist/35/rpg-35.txt | wc -l | awk '{print "35\t"$1}'
grep -v "^$" ../results_corr_consist/15/rpg-15.txt | wc -l | awk '{print "15\t"$1}'
grep -v "^$" ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt | wc -l | awk '{print "rpg-55bac_arch-75euk-ASMean\t"$1}'
echo 
echo "nUnique UP"
grep -v "^$" ../results_corr_consist/95/rpg-95.txt | awk '{print $1}' | sed 's/>//' | sort -u | wc -l  | awk '{print "95\t"$1}'
grep -v "^$" ../results_corr_consist/75/rpg-75.txt | awk '{print $1}' | sed 's/>//' | sort -u | wc -l  | awk '{print "75\t"$1}'
grep -v "^$" ../results_corr_consist/55/rpg-55.txt | awk '{print $1}' | sed 's/>//' | sort -u | wc -l  | awk '{print "55\t"$1}'
grep -v "^$" ../results_corr_consist/35/rpg-35.txt | awk '{print $1}' | sed 's/>//' | sort -u | wc -l  | awk '{print "35\t"$1}'
grep -v "^$" ../results_corr_consist/15/rpg-15.txt | awk '{print $1}' | sed 's/>//' | sort -u | wc -l  | awk '{print "15\t"$1}'
grep -v "^$" ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt | awk '{print $1}' | sed 's/>//' | sort -u | wc -l | awk '{print "rpg-55bac_arch-75euk-ASMean\t"$1}'

echo 
echo "Check Outstanding Cases"
perl checkOutstandingRP.pl ../results_corr_consist/95/rpg-95.txt
perl checkOutstandingRP.pl ../results_corr_consist/75/rpg-75.txt
perl checkOutstandingRP.pl ../results_corr_consist/55/rpg-55.txt
perl checkOutstandingRP.pl ../results_corr_consist/35/rpg-35.txt
perl checkOutstandingRP.pl ../results_corr_consist/15/rpg-15.txt
perl checkOutstandingRP.pl ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt
