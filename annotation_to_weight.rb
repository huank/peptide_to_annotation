require 'yaml'
ext = ".annotation_to_weight.yml"
if ARGV.size != 2
 puts "usage: #{File.basename($0)} <file>.tsv(Proeome Discoverer default export) <file>.tsv(peptide_to_annot_database)"
 puts "output: <file>#{ext}"
 exit
end
default_export_file = ARGV[0]
Peptide_to_annotation_db = ARGV[1]

base = pep_to_prot_file.chomp(File.extname(default_export_file))

outfile = base + ext


peptide_with_PSM = Hash.new #{|h,k| h[k] = []}
sequence = Array.new
 File.open(default_export_file) do |io|
 header = io.readline
  io.each_line do |line|
  pep = line.split("\t")
	seq = pep[3].split("\"")
	seq = seq[1]
   seq.	
	 sequence << seq	 
	if peptide_with_PSM.key? seq   
	 peptide_with_PSM [seq] = peptide_with_PSM [seq] +1
	else
	peptide_with_PSM [seq] = 1		 
	end
 end
end
#puts peptide_with_PSM["VGIENIGR"]  
tic = sequence.size.to_f

annotation_to_weight = Hash.new
peptide_with_PSM.each_key do |search|

IO.foreach(Peptide_to_annotation_db) do |line|
 (pep, *goannots) = line.split(": ")
 annot = goannots[0].split("\n")
 annot = annot[0].split("\t") 
 
 m = annot.size.to_f
 weight_of_annotation = 1/m
 
 n = 0 
 
 if search == pep   #some peptides have modification in there
 while n <annot.size
    annotation = annot[n] 
    psm = peptide_with_PSM[search].to_f / tic
	
	if annotation_to_weight.key? annotation
	annotation_to_weight[annotation] = annotation_to_weight[annotation] + weight_of_annotation * psm
	else
	annotation_to_weight[annotation] = weight_of_annotation* psm
	end
	n = n+1
end
puts "."
File.write(outfile, annotation_to_weight.to_yaml)
 end

end

end
