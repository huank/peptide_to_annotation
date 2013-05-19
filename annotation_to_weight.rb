require 'yaml'
ext = ".annotation_to_weight.yml"

def tell_how_long(&block)
  puts "starting to time now!" ; $stdout.flush
  start = Time.now
  reply = block.call
  puts "Took #{Time.now - start} seconds"
  reply
end

if ARGV.size != 2
  puts "usage: #{File.basename($0)} <file>.tsv(Proeome Discoverer default export) <file>.tsv(peptide_to_annot_database)"
  puts "output: <file>#{ext}"
  exit
end

(default_export_file, peptide_to_annotation_db) = ARGV

base = pep_to_prot_file.chomp(File.extname(default_export_file))
outfile = base + ext

peptide_with_PSM = Hash.new {|h,k| h[k] = 0 }

File.open(default_export_file) do |io|
  header = io.readline
  io.each_line do |line|
    data = line.split("\t")
    seq = data[3].split('"').last
    peptide_with_PSM[seq] += 1
  end
end

peptide_to_annot = {}
tell_how_long {
  IO.foreach(peptide_to_annotation_db) do |line|
    line.chomp!
    peptide_to_annot.store( *line.split(': ') ) # storing value as a string!
  end
}


total_psms = peptide_with_PSM.values.reduce(:+)


annotation_to_weight = Hash.new {|h,k| h[k] = 0.0 }

peptide_with_PSM.each do |query_peptide, spectral_hit_cnt|
if peptide_to_annot[query_peptide]
  annotations = peptide_to_annot[query_peptide].split("\t")
  weight_of_annotation = 1.0 / annotations.size

  annotations.each do |annotation|

    nrmlzed_psm_cnt = spectral_hit_cnt.to_f / total_psms

    annotation_to_weight[annotation] += (weight_of_annotation * nrmlzed_psm_cnt)
  end
end
end

File.open(outfile,"w") do |out|
  out.write(annotation_to_weight.to_yaml)
end

