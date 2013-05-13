require 'yaml'
ext = ".peptide_to_annot.yml"
if ARGV.size == 0
 puts"usage: #{File.basename($0)} <file>.yml(peptide_to_protIDs) <file>.tsv(protIDs_to_annotion)"
 puts "output: <file#{ext}>.yml(peptide_to_annotations)"
 exit
end

peptide_to_proIDs_file = ARGV[0]
proIDs_to_annot_file = ARGV[1]
output = YAML::load(File.open(peptide_to_proIDs_file))
peptide_to_ID_hash = Hash.new

output.each do |peptide, protIDs|
  prot = protIDs.split("\t")
    prot.each do |prot_id|
	peptide_to_ID_hash [peptide] = prot_id
    end
end

protIDs_to_annot_hash = Hash.new
IO.foreach(proIDs_to_annot_file) do |line| 

 (data, *anno) = line.split("\t")		
  if protIDs_to_annot_hash.key?(data)
    protIDs_to_annot_hash[data] << anno[3]+"\t"  
  else
    protIDs_to_annot_hash[data] = anno[3]+ "\t" 
  end 
end


peptide_to_ID_hash.each_key do |key| 
 if  protIDs_to_annot_hash.key? peptide_to_ID_hash[key]    
   data = peptide_to_ID_hash[key] 
   peptide_to_ID_hash[key] = protIDs_to_annot_hash[data]		
 else 			
   peptide_to_ID_hash.delete(key)
 end
end
	
file = ARGV[1]
base = File.basename(file).split(".")[0]
outfile = base + ext
File.open(outfile, "w") do |file|
 file.write peptide_to_ID_hash.to_yaml
end
