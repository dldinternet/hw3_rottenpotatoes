# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    m = Movie.new(movie)
    m.save!()
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  flunk "Unimplemented"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: *(.*)$/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  #puts "uncheck '#{uncheck.to_s}'"
  #puts "rating_list '#{rating_list.to_s}'"
  rating_list.split(/,/).each do |r|
    step %Q{I #{uncheck}check "ratings_#{r}"}
  end
end

When /^I uncheck all the ratings checkboxes$/ do
  step "I uncheck the following ratings: #{Movie.all_ratings().join(',')}"
end

When /^I (un)?check the (.*) checkboxes?$/ do |uncheck, list|
  #puts "list '#{list}'"
  @list = list.gsub(/(\s|and|or)/,',').gsub(/['"]/,'').gsub(/,+/,',')
  #puts "list '#{@list}'"
  checks = @list.split(/,/)
  #puts "checked '#{checks}'"
  step "I #{uncheck}check the following ratings: #{@list}"
end

When /^I check only the (.*) checkboxes?$/ do |list|
  step 'I uncheck all the ratings checkboxes' 
  @list = list.gsub(/(\s|and|or)/,',').gsub(/['"]/,'').gsub(/,+/,',')
  checks = @list.split(/,/)
  step "I check the following ratings: #{@list}"
end

When /^(?:|I )(press|click) the "([^"]*)" button/ do |press,button|
  #puts "''#{press}' '#{button}'"
  step %Q{I press "#{button}"} 
end

Then /^I should (not )?see (.*) rated movies$/ do |neg,rating_list|
  step "I should #{neg}see movies with the following ratings: #{rating_list}"
end

Then /^I should (not |)see movies with the following ratings: *(.*)$/ do |neg,rating_list|
  @list = rating_list.gsub(/(\s|and|or)/,',').gsub(/['"]/,'').gsub(/,+/,',').split(/,/)
  #puts "list '#{@list}' neg '#{neg}'"
  @found = {}
  html = Nokogiri::HTML(page.body)
  movies = html.css('table#movies tbody')
  movies.children.each do |row|
    fields = row.children
    name = fields[0].children[0]
    rate = fields[2].children[0]
    date = fields[4].children[0]
    link = fields[6].children[0]
    #puts "'#{name}' '#{rate.to_s}' '#{date}'"
    #puts "#{@list.include?(rate.to_s)} '#{rate.to_s}'"
    @found[rate.to_s] = 1 if @list.include?(rate.to_s)
  end
  #puts "found '#{@found.keys}' #{@found.keys.count}"
  ok = false
  #debugger
  ( ( (@found.keys.count > 0) && neg.empty? ) || ( (not neg.empty?) && (@found.keys.count == 0) ) ).should  == true 
end
