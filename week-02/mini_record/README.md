# MiniRecord

The **MiniRecord** library is meant to give you insight into how ActiveRecord does its work and make it less "magical."  The fundamental idea behind ActiveRecord is that tables in your database map to Ruby classes and rows in your tables map to instances of those Ruby classes.

One consequence of this is that the Ruby class is responsible for table-level and schema-level details, while instances of those classes are responsible for row-level details.  For example, whether a particular table has a given field/column or not is something the "schema" is responsible for knowing, which means that in our Ruby code it should be something the corresponding class is responsible for knowing.

The goal of this kata is to refine the "bare bones" version of the **MiniRecord** library to add some of the ActiveRecord-type magic.

## Usage

Make sure you create an empty users database first by running

```console
$ sqlite3 blog.db < setup.sql
```

Once you've done that, look at `test_blog.rb`.  You should be able to run it without a hitch.  This code can also serve as a "test bed" for you as you make changes to the code.

If this doesn't work, make sure you've set up the database correctly.

## Key Classes

There are two key classes in the MiniRecord library:

1.  `MiniRecord::Database`

    The `MiniRecord::Database` class is responsible for managing the database connection and sending queries to the database.  In our case, this is mostly a lightweight wrapper around the `SQLite3::Database` class.

    The most important thing to know is that before you can do _anything_ with MiniRecord, you have to tell it what database file to use.  You do it like so:

    ```ruby
    MiniRecord::Database.database = 'users.rb'
    ```
2.  `MiniRecord::Model`

    The `MiniRecord::Model` class is the base class for all our database models.  Over the course of the kata, you'll be moving code out of specific models like `User`, generalizing it, and adding it to this base class.

    **Hint**: If you're running code in an _instance_ of a class, you can call `self.class` to get the current instance's class.  For example, if `@user` is an instance of `User` then `@user.class` will return the _actual_ `User` class.  This is the key indirection you'll need to generalize your code.

## Iterations

### v0.1 (Status Quo)

In the current version the `User` model contains a _ton_ of code.  Compare it to the `BlogPost` model, which _also_ contains a ton of code.  Here's the thing, though: the code in the `BlogPost` and `User` is very similar.

Since both `User` and `BlogPost` share from inherit from the same base class (`MiniRecord::Model` in this case), this _screams_ "refactor the common code into the base class!"

### v0.2 (Refactoring Into Base Class)

Your goal is to remove all the common parts of `User` and `BlogPost` and move them into `MiniRecord::Model`.  At the end of the process, your models should look like this and behave **identically** to how they behaved before.

```ruby
class User < MiniRecord::Model
  self.table_name = :users
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

class BlogPost < MiniRecord::Model
  self.table_name = :blog_posts
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
```

You'll have to define class-level methods called `table_name` and `table_name=` on `MiniRecord::Model` because the (abstract) base class doesn't know the table name.  Use this method where the various table names (`users`, `blog_posts`, etc.) were hard-coded before.

### v0.3 (Dynamic Attribute Names)

It sucks that we have to specify both the name of the table and list out all the attributes.  Let's change it so that once we set the table name, we pull in a list of attributes automatically from the database.

To do this, SQLite3 has a special "meta-query" that returns a result set containing schema data.  This is the query:

```sql
PRAGMA table_info(users);
```

This means you can run, e.g.,

```ruby
MiniRecord::Database.execute("PRAGMA table_info(users)")
```

and get back a `Hash` that contains information about the `users` table, including what fields it has.  We can then iterate through this result set to produce a list of valid attribuets and call `MiniRecord::Model.attributes=` with that list.

If you modify `MiniRecord::Model.table_name=` to do this work you'll be able to have a `User` class that looks like

```ruby
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
```

That's pretty ActiveRecord-like, isn't it?!

### v0.4 (Your Own ActiveRecord Feature)

Pick a basic ActiveRecord feature or method and try to implement it yourself.
