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
  step "the following checkboxes should #{neg}be checked: #{rating_list}"
  step "I should #{neg}see movies with the following ratings: #{rating_list}"
end

Then /^I should (not |)see movies with the following ratings: *(.*)$/ do |neg,rating_list|
  ratings = rating_list.gsub(/(\s|and|or)/,',').gsub(/['"]/,'').gsub(/,+/,',').split(/,/)
  Movie.all_ratings().each do |checkbox|
    regexp = /^#{checkbox}$/
    if ratings.include? checkbox
      if neg.empty?
        if page.respond_to? :should
          page.should have_xpath('//td', :text => regexp)
        else
          assert page.has_xpath?('//td', :text => regexp)
        end
      else
        if page.respond_to? :should_not
          page.should have_no_xpath('//td', :text => regexp)
        else
          assert page.has_no_xpath?('//td', :text => regexp)
        end
      end
    else
      if neg.empty?
        if page.respond_to? :should
          page.should have_no_xpath('//td', :text => regexp)
        else
          assert page.has_no_xpath?('//td', :text => regexp)
        end
      else
        if page.respond_to? :should
          page.should have_xpath('//td', :text => regexp)
        else
          assert page.has_xpath?('//td', :text => regexp)
        end
      end
    end
  end
end

Then /^I should see all of the movies/ do
  movie_count = Movie.all.count
  #puts "I count #{movie_count} movies"
  row_count = page.all('tbody/tr').count
  row_count.should == movie_count
end

When /(all|no) ratings selected/ do |all|
  #handler = all ? check : uncheck
  Movie.all_ratings.each do |rate|
    case 'all'
    when'all' then check 'ratings_' + rate
    else uncheck 'ratings_' + rate
    end
  end

  click_button('ratings_submit')
end

And /^the following checkboxes should (not )?be checked: (.*)$/ do |un, rating_list|
  # We have captured the ratings that we want displayed
  rating_list.to_s.gsub(/\sand/,',').gsub(/\s/, "").gsub(/['"']/,'').split(",").each do |r|
    step %Q{the "ratings_#{r}" checkbox should #{un}be checked}
  end
end
