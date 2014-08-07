class User < MiniRecord::Model
  self.attribute_names = [:id, :first_name, :last_name, :email, :birth_date, :created_at, :updated_at]

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
