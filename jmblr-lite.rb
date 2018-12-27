#!/usr/bin/ruby -w
# Written by Sourav Goswami - https://github.com/Souravgoswami/
# GNU General Public License v3.0
# Version 1.5

require 'io/console'
STDOUT.sync, STDIN.sync = true, true

# Set the default path for the word file
Default_Path = "#{File.dirname(__FILE__)}/words"

path = nil

word_arg = ARGV.select { |arg| arg.start_with?('--words=') || arg.start_with?('-w=') }
word_arg.each { |arg| ARGV.delete(arg) }

unless word_arg.empty?
	word_arg = word_arg[-1].split('=')[1]
	unless word_arg.nil?
		path = word_arg if File.exist?(word_arg)
	end
end

path = Default_Path if path.nil?

if ARGV.to_a.include?('-h') or ARGV.include?('--help')
puts(
"Hi my name is Jumbler! Also known as jmblr...
I am a small program to whom you give jumbled up word(s), and get matching words.

Arguments:
	--help			-h	Show this help message.

	--update		-u	Download missing dictionary
						from the internet.
					       (update if available)

	--random		-r	Select a random word for fun

	--words=		-w=	Specify the wordlist that will be
						used for searching.")
puts "\n" * 2
exit! 0
end

update = -> do
	begin
		puts "Update the database? (N/y): "
		exit! 0 unless STDIN.gets.chomp.downcase.start_with?('y')

		require 'net/http'
		site = "https://raw.githubusercontent.com/Souravgoswami/jmblr/master/words"

		puts "Downloading data from #{site}"
		puts

		data = Net::HTTP.get(URI("#{site}"))
		unless data.chomp == '404: Not Found'
			puts "Writing #{(data.chars.size/1000000.0).round(2)} MB to #{path}. Please Wait a Moment"

			begin
				unless File.exist?(path.split('/')[0..-2].join('/'))
					Dir.mkdir(path.split('/')[0..-2].join('/'))
				end

				File.open(path, 'w+') { |file| file.write(data) }

			rescue Errno::ENOENT
				puts "Directory doesn't exist. Please create a directory #{path.split('/')[0..-2].join('/')}/"
				puts "The file I am trying write to is: #{path}"
				exit! 126

			rescue Errno::EACCES
				puts "To write to #{path}, you need root privilege..."
				exit! 126

			rescue SocketError
				puts 'Make sure you have an active internet connection'
				puts 'Retry? (N/y)'
				retry if  STDIN.gets.strip.downcase == 'y'
				exit! 126
			end

			puts "All done! The file has been saved to #{path}. Run #{__FILE__} to begin solving puzzles!"
			exit! 0
		else
			puts 'Uh Oh! The update is not successful. If the problem persists, please contact the developer: <souravgoswami@protonmail.com>'
			exit! 126
		end

	rescue Exception => error
		puts 'Something went wrong.'
		puts 'If the problem persists, then please contact the developer'
		puts 'Email: <souravgoswami@protonmail.com>'
		puts "Inform the developer about \"#{error}\""
		puts error.backtrace.join("\n")
		exit! 127
	end
	exit! 0
end

unless File.readable?(path)
	puts File.exist?(path) ? "The #{path} file is not readable! How can I read my words? :(" : "The #{path} file doesn't exist. Where are my words? :'("

	puts "Please run #{__FILE__} --update or #{__FILE__} -u to download the wordlist"
	puts "You can mention the path with --words=path or -w=path option"
	puts "Run #{__FILE__} --help or #{__FILE__} -h for more details"
	puts 'However, you can run the update now. Do you want that?(Y/n)'
	exit! 120 if gets.strip.downcase == 'n'
	update.call
end

# exit if no tty found
begin
	Terminal_Width, Terminal_Height = STDOUT.winsize[1], STDOUT.winsize[0]

rescue Errno::ENOTTY
	puts "The window size can't be determined. Are you running me in a terminal?"
	exit! 2
end

update.call if ARGV.include?('-u') or ARGV.include?('--update')

puts 'Just a moment...'

unsorted = File.readlines(path).map(&:strip).map(&:downcase).select { |i| i =~ /^[a-z]+$/}.uniq
sortedwords = unsorted.map { |ch| ch.chars.sort.join }
unsorted_size = unsorted.size

search = ->(arg) do
	puts "Possible matches for #{arg.strip.downcase}:\n\n"
	arg = arg.strip.downcase.chars.sort.join
	unsorted_size.times { |i| puts unsorted[i] if sortedwords[i] == arg }
	puts
end

if ARGV.include?('--random') || ARGV.include?('-r')
	search.call(File.readlines(path).sample.strip.chars.shuffle.join)
	ARGV.delete('--random')
	ARGV.delete('-r')
	exit if ARGV.empty?
end

pipe, texts = nil, ''
require 'timeout'
begin
	Timeout::timeout(0.00000000000000000000001) { pipe = STDIN.gets }
rescue Exception
end

if pipe
	texts += pipe

	loop do
		val = STDIN.gets
		break if val.nil?
		texts += val
	end
	texts.split.each { |text| search.call(text) }
	exit if ARGV.empty?
end

unless ARGV.empty?
	ARGV.each { |text| search.call(text) }
else
	loop do
		begin
			print 'Type jumble word: '
			search.call(STDIN.gets)
		rescue Interrupt
			puts
			exit! 0
		rescue Exception
			exit! 128
		end
	end
end
