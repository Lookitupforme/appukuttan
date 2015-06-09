#Credits
# First https://gist.github.com/mattdipasquale/571405
# Then https://gist.github.com/georgy7/a8ab4d5a2e90282b189c which forked the above

#Intro
puts "I will iterate through all the files in the directory you specify. I will find all the *.* files and check if there are duplicates. If there are duplicates, I will copy them over to the place you specify.\n"
puts

# Get source of photos
puts "Which directory would you like me to traverse?"
source_dir = gets.chomp
# source_dir ||= '/Volumes/Photos/backup-before-processing/iPhoto Library/Masters/2008/2008.04.14.Kids.playing.Beulah.babyshower.2008.science.fair'

unless Dir.exist?(source_dir)
  puts "The source directory #{source_dir} does not exist"
  exit
end

# Get where to put the photos
puts "In which directory do you want me to put the duplicates?"
duplicates_dir = gets.chomp
# duplicates_dir ||= '/tmp/jv/dupes'

if source_dir == duplicates_dir
  puts "The directory where I put the duplicates cannot be the same directory as the source directory. Sorry... please try again."
end

# Create the output directory if it does not exist
require 'fileutils'
FileUtils::mkdir_p duplicates_dir

# Ensure the file to store the duplicate names does not exist already
dupes_file = File.join(duplicates_dir, "duplicates.json")
if File.exist?(dupes_file)
  puts "#{dupes_file} already exists, please do the needful." 
  exit
end

## Now the meat of the program
require 'digest/md5'
puts "Iterating through all the subdirectories of #{source_dir}. This could take a while depending on how many files I find."
puts "Tell you what... for every 10 files I process, I'll print a dot."

full_list = {}
num_files_checked = 0

Dir.glob("#{source_dir}/**/*", File::FNM_DOTMATCH).each do |filename|
  next if File.directory?(filename)

  begin
    key = Digest::MD5.hexdigest(IO.read(filename)).to_sym
    if full_list.key? key
      full_list[key].push filename
    else
      full_list[key] = [filename]
    end
  rescue
    puts "Error processing #{filename}"
  end

  num_files_checked += 1
  print '.' if 0 == num_files_checked % 10
  puts "#{num_files_checked} done. Now processing ...#{File.dirname(filename)[-60..-1]}" if 0 == num_files_checked % 100
end

puts "Done processing #{num_files_checked}. Extracting duplicates"

duplicates = full_list.select{|k, v| v.count > 1}



puts "Writing list of duplicates to #{dupes_file}"

require 'json'
File.open(dupes_file, 'w') do |f|
  f.write JSON.pretty_generate(duplicates)
end


puts "Copying the duplicate files to the #{duplicates_dir} for further visual review"
duplicates.each do |md5, files|
  files.each do |f|
    FileUtils.cp(f, "#{duplicates_dir}/#{md5}_#{File.basename(f)}")
  end
end









