class User < MiniRecord::Model
  self.table_name = :users

  def blog_posts
    BlogPost.where('user_id = ?', self[:id])
  end

  # e.g.,
  #   user.create_blog_post(title: 'My Post', content: 'Best blog post ever!')
  def create_blog_post(attributes = {})
    attributes[:user_id] = self[:id]
    BlogPost.create(attributes)
  end
end
