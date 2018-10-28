#!/usr/bin/env ruby
# Written by Sourav Goswami - https://github.com/Souravgoswami/
# GNU General Public License v3.0

if ARGV.include?('-h') or ARGV.include?('--help')
puts <<EOF
Hi my name is Jumbler-Lite! Also known as jmblr-lite...
I am the lighter brother of Jumbler. But I will show the same output, but real time search is not possible. Because I am lite brother...
I am a small program where you will give me a jumpled up word(s), and I try to solve that with my tiny brain.

What job can I accomplish?
	-> When you run me, I will ask you to type your word. I will show my calculation in real time.
	- Sorry if I take some time to solve your jumbled up word - I still have to do all my calculations.
	- But I will try my best to solve the word as fast as possible. Probably some milliseconds...
	-> Remember to press the escape key when you want to leave!

	-> You can pass me some command line arguments as well!
	-> I will accept one or more than one word as argument. I will solve them one by one.
	-> I will not show any result if I don't get something meaningful from your jumbled word(s).

Arguments:
	--help		-h		Show this help message.

	--update	-u		Download missing dictionary from the internet(update if available)
				(Note that if the application is working, there's no need to update the database).

	Note: I am the light weight version of jmblr! Unfortunately, My heavier brother is cooler than me 8(
EOF
exit! 0
elsif ARGV.include?('-u') or ARGV.include?('--update')
	print "Update the words database? (This is not needed if the program is working) (N/y): "
	exit! 0 unless STDIN.gets.chomp.downcase == 'y'

	begin
		require 'net/http'
		puts 'Downloading data from https://raw.githubusercontent.com/Souravgoswami/jmblr/master/words'
		puts 'Please wait'
		data = Net::HTTP.get(URI('https://raw.githubusercontent.com/Souravgoswami/jmblr/master/words'))
		unless data.chomp == '404: Not Found'
			file = File.open('words', 'w')
			puts "Downloaded #{data.chars.size} MB.", "Writing data to #{Dir.pwd}/words"
			file.write(data)
			file.close
			puts "Successfully written data to #{Dir.pwd}/words", "Loading #{__FILE__}"
		else
			puts 'Uh Oh! The update is not successful. If the problem persists, please contact the developer: souravgoswami@protonmail.com'
			exit! 128
		end
	rescue Exception
		puts "The site https://raw.githubusercontent.com/Souravgoswami/jmblr/master/word is not reachable at the moment."
		puts "Please make sure that you have an active internet connection."
		exit! 127
	end
	ARGV.delete('-u')
	ARGV.delete('--update')
end

print "Loading, please wait...\n\n"

unsorted = File.open('words').readlines.map(&:chomp).map(&:downcase).select { |i| i =~ /^[a-z]+$/}
sortedwords = unsorted.map { |ch| ch.split('').sort.join }

unless ARGV.empty?
	ARGV.each do |index|
		w = index.downcase.split('').sort.join
		sortedwords.each_with_index do |sw, i| puts "#{unsorted[i]}" if sw == w end
		puts
	end
else
	loop do
		print "\nType a word: "
		search = STDIN.gets.chomp.downcase.split('').sort.*('')
		sortedwords.each_with_index do |sw, i| puts "#{unsorted[i]}" if sw == search end
		print "Search for more words? (Y/n): "
		exit! 0 if gets.chomp.downcase == 'n'
	end
end
