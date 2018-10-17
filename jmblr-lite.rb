#!/usr/bin/env ruby
# Written by Sourav Goswami - https://github.com/Souravgoswami/
# GNU General Public License v3.0

if !ARGV[0].match(/^[a-z]/)
puts <<EOF
Hi my name is Jumbler-Lite! Also known as jmblr-lite...
I am the lighter brother of Jumbler. But I will show the same output, but real time search is not possible. Because I am lite brother...
I am a small program where you will give me a jumpled up word(s), and I try to solve that with my tiny brain.

What job can I accomplish?
	When you run me, I will ask you to type your word. I will show any match word.
	Sorry if I take some time to figure out your jumbled up word - I still have to do all my calculations.
	But I will try my best to solve the word as fast as possible. Probably some milliseconds...

	You can pass me some command line arguments as well!
	I will accept one or more than one word as argument. I will solve them one by one.
	I will not show any result if I don't get something meaningful from your jumbled word(s).

	Note: I am the light weight version of jmblr! Unfortunately, My heavier brother is cooler than me 8(
EOF
exit! 0
end unless ARGV[0].nil?

$status = nil
Thread.new {
	loop do
	'|/-\\'.chars do |ch| print "#{ch}\r"
		break if $status
		sleep 0.03
	end
	end
}

unsorted = File.open('words').readlines.map(&:chomp).map(&:downcase).select { |i| i =~ /[a-z]/}
sortedwords = unsorted.map { |ch| ch.split('').sort.join }
$status = ''

unless ARGV.empty?
	ARGV.each do |index|
		sortedwords.each_with_index do |sw, i| puts "\033[1;33m#{unsorted[i]}" if sw == index.downcase.split('').sort.join('') end
	end
else
	print "Enter a word: "
	search = gets.chomp.downcase.split('').sort.*('')
	sortedwords.each_with_index do |sw, i| puts "\033[1;32m#{unsorted[i]}" if sw == search end
end
