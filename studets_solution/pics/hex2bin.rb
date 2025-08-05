def stringToBin(hex)
  return hex-48 if hex <58 # digit
  return hex-55
end

inputFile, outputFile = ARGV[0..1]

wfd=File.open(outputFile, 'w')
IO.readlines(inputFile).each do |line|
  line=line.gsub(/\s/, '').upcase.reverse
  (0...line.size).each do |i|
    if i%2==1
      wfd.print(((stringToBin(line[i])*16) + stringToBin(line[i-1])).chr) 
    end
  end
end

wfd.close

      
     
       
  
