#!/usr/bin/env ruby

require 'yaml'

ext = ".peptide_to_annot.yml"

if ARGV.size != 2
 puts "usage: #{File.basename($0)} <file>.yml(pep_to_protIDs) <file>.tsv(protIDs_to_annot)"
 puts "output: <file>#{ext}"
 exit
end

(pep_to_prot_file, prot_to_annot_file) = ARGV

def get_pep_to_prot(file)
  pep_to_prot = YAML.load_file(file)

  def pep_to_prot.prot_ids(peptide)
    prot_s = self[peptide]
    if prot_s  # might be nil
      prot_s.split("\t")
    else
      nil
    end
  end
  pep_to_prot
end

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


pep_to_prot = get_pep_to_prot(pep_to_prot_file)

base = pep_to_prot_file.chomp(File.extname(pep_to_prot_file))
outfile = base + ext

File.open(outfile, "w") do |out|

  pep_to_prot.keys.each do |pep| 

    pep_to_prot.prot_ids(pep).each do |prot_id|

      if  prot_to_annot.pep?(pep_to_prot[pep])
        out.puts "#{pep}: #{prot_to_annot[prot_id].join("\t")}"
      end

    end
  end

end
