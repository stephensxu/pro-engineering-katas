class BlogPost < MiniRecord::Model
  self.table_name = :blog_posts

  def user
    User.find(self[:user_id])
  end

  def user=(user)
    self[:user_id] = user[:id]
    self.save
    user
  end
end
