require './mini_record'
require './user'
require './blog_post'

MiniRecord::Database.database = 'blog.db'

jesse = User.where('email = ?', 'jesse@codeunion.io').first

if jesse.nil?
  jesse = User.new
  jesse[:first_name] = 'Jesse'
  jesse[:last_name]  = 'Farmer'
  jesse[:email]      = 'jesse@codeunion.io'
  jesse[:birth_date] = Date.parse('1983-10-15')

  jesse.save
end

jesse.create_blog_post(title: 'My Awesome Post!', content: 'This is my blog post.')

puts "Here are all the blog posts:"
puts ""

BlogPost.all.each_with_index do |blog_post, index|
  puts "#{index + 1}. #{blog_post[:title]}"
  puts "by #{blog_post.user[:first_name]} #{blog_post.user[:last_name]}"
  puts ""
  puts blog_post[:content]
  puts "------"
  puts ""
  puts ""
end
