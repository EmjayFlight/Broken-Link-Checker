class BrokenLinkChecker
	def initialize
require 'open-uri'
require 'net/http'
require 'gmail'

startTime = Time.now

urlFile = File.open('urlFiles.txt', 'r') #urlFiles.txt is the file being used by creator to test the functionality of this code

contents = urlFile.read

urlTest = contents.split(' ')

puts "How many URL's would you like to test?"

testReq = gets.chomp

if testReq.to_i == 0 
	puts "No items to be tested. Check that you've entered a numerical value."
	abort()
end

urlTest = urlTest.first(testReq.to_i)

#Runs Test for Malformed URLS and sorts untestable and testable into their own respective arrays
malformedExpressions = []
goodURLs = []
dontRun = []
regex = /https?:\/\//
regDR = /#/
urlTest.each do |i|
if regDR.match(i) != nil
	dontRun.push(i)
elsif regex.match(i) == nil
malformedExpressions.push(i)
else
	goodURLs.push(i)
end
end

#Removes any whitespace that may occur due to accidental user input
goodURLs.each do |i|
	i.strip
end

puts goodURLs.length.to_s + " URL's are being checked with this test. " + malformedExpressions.length.to_s + " were found to be untestable due to inproper user input. " + dontRun.length.to_s + " were exempted from this test."

informationalURL = []
successfulURL = []
redirectionURL = []
clientError = []
serverError = []
brokenURL = []

goodURLs.each do |i|
	uri = URI(i)
	res = Net::HTTP.get_response(uri)
	if res.code >= '100' && res.code < '200'
	informationalURL.push(i)
elsif res.code >= '200' && res.code < '300'
	successfulURL.push(i)
elsif res.code >= '300' && res.code < '400'
	redirectionURL.push(i)
elsif res.code >= '400' && res.code != '404' && res.code < '500'
	clientError.push(i)
elsif res.code >= '500' && res.code < '600'
	serverError.push(i)
else 
	brokenURL.push(i)
end
end

if informationalURL.length == 0
	puts "No informational URL's were found."
else
	puts informationalURL.length.to_s + " item(s) determined to be informational."
end

if successfulURL.length == 0
	puts "No succesful URL's were found."
else
	puts successfulURL.length.to_s + " item(s) were successful URL's with a 200 code."
end

if redirectionURL.length == 0
	puts "No redirection URL's found."
else
	puts redirectionURL.length.to_s + " item(s) redirected to another site."
end

if clientError.length == 0
	puts "No client errors found."
else
	puts clientError.length.to_s + " item(s) were determined to have client errors."
end

if serverError.length == 0
	puts "No server-side errors found"
else
	puts serverError.length.to_s + " item(s) were determined to have server errors."
end

if brokenURL.length == 0
	puts "No 404 errors found"
	else
		puts brokenURL.length.to_s + " item(s) yielded 404 Broken Link Errors!"
	end

runTime = Time.now - startTime
if runTime >= 60
runMinutes = runTime/ 60
puts "Total time elapsed to run test: #{runMinutes} minute(s)."
else
	puts "Total time elapsed to run test: #{runTime} seconds."
end

puts "What is your email?"
$email = gets.chomp

puts "What is your email password? Don't worry! It's our secret!"
$password = gets.chomp

puts "What is the name of the person you'll be sending this to?"
recipient = gets.chomp

puts "What is the recipient's email?"
$recipientEmail = gets.chomp

$publishResults = 'Hey ' +recipient+ '! I\'ve created the 404 finder as you asked. Here are the results: 
We ran ' + goodURLs.length.to_s + ' URL\'s with this test.
There were ' + informationalURL.length.to_s + ' URL\'s were informational in nature. 
There were ' + successfulURL.length.to_s + ' URL\'s worked as intended. 
There were ' + redirectionURL.length.to_s + ' URL\'s redirected to some other site.
There were ' + clientError.length.to_s + ' URL\'s that were not functional due to client side errors.
There were ' + serverError.length.to_s + ' URL\'s that were not functional due to server side errors.
Most importantly: There\'s ' + brokenURL.length.to_s + ' in the set you provided. Here are the 404 error URL\'s: ' + brokenURL.to_s +

'Good day!
Matthew Johnson'


def email()
  gmail = Gmail.connect($email , $password)
  gmail.deliver do
    to $recipientEmail
    subject "Broken Links Test"
    text_part do
      body $publishResults
    end
    #add_file 'results.txt'
  end
  gmail.logout
end
email()
end
end