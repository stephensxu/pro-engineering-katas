class BlogPost < MiniRecord::Model
  self.attribute_names = [:id, :user_id, :title, :content, :created_at, :updated_at]

  def user
    User.find(self[:user_id])
  end

  def user=(user)
    self[:user_id] = user[:id]
    self.save
    user
  end
end
