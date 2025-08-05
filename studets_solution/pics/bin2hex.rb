fd=File.open(ARGV[0])
fw=File.open(ARGV[1], 'w')
c=-1
while tmp=fd.read(4)
  tmp.reverse!
  (0...tmp.size).each do |i|
    k=tmp[i].to_s(16)
    k='0'+k if k.size==1
    fw.print k
  end
  fw.puts "            // #{c+=1}"
end
fd.close
fw.close


