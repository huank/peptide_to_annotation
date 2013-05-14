#!/usr/bin/env ruby

require 'yaml'

ext = ".peptide_to_annot.tsv"

if ARGV.size != 2
 puts "usage: #{File.basename($0)} <file>.yml(pep_to_protIDs) <file>.tsv(protIDs_to_annot)"
 puts "output: <file>#{ext}"
 exit
end

(pep_to_prot_file, prot_to_annot_file) = ARGV


def get_prot_to_annot(file)
  prot_to_annot = Hash.new {|h,k| h[k] = [] }
  File.open(file) do |io|
    header = io.readline
    io.each_line.with_index do |line,i|
      (prot_id, *anno) = line.split("\t")  	
      prot_to_annot[prot_id] << anno[2]
      if (i % 10000) == 0
        print '.' ; $stdout.flush
      end
    end
  end
  prot_to_annot
end
prot_to_annot = get_prot_to_annot(prot_to_annot_file)

base = pep_to_prot_file.chomp(File.extname(pep_to_prot_file))
outfile = base + ext

File.open(outfile, "w") do |out|
 IO.foreach(pep_to_prot_file) do |line|
  (pep, *protIDs) = line.split(": ")   #print protIDs["Q66D69"] ; print protIDs[0]

    str_total = protIDs[0].split("\n")
	str = str_total[0].split("\t")
	n = 0	
	anno = []
	while n < str.size
	id = str[n]
	
	 anno << prot_to_annot[id] if prot_to_annot[id] != []
     n = n+1
	
    end

	out.puts "#{pep}: #{anno.join("\t")}" if anno != []
	
	end
end
