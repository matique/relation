# Relation

[![Gem Version](https://img.shields.io/gem/v/relation?color=168AFE&logo=rubygems&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![Downloads](https://img.shields.io/gem/dt/relation?color=168AFE&logo=rubygems&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![GitHub Build](https://img.shields.io/github/actions/workflow/status/matique/relation/rake.yml?logo=github)](https://github.com/matique/relation/actions/workflows/rake.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-168AFE.svg)](https://github.com/standardrb/standard)
[![MIT License](https://img.shields.io/badge/license-MIT-168AFE.svg)](http://choosealicense.com/licenses/mit/)

Relation provides a generic way to establish relationships between
arbitrary ActiveRecord records without adding foreign keys,
association columns, or dedicated join tables
to the respective model tables.

All relationships are stored in a single additional database table.

~~~ruby
Relation.add order, user
Relation.add order, product
Relation.add order, another_user

Relation.references order, User    # => [user, another_user]
Relation.references order, Product # => [product]

Relation.followers user, Order     # => [order]
~~~

Relationships can connect records of different models,
including records belonging to the same model.

## Why Relation?

Rails provides several mechanisms for modeling database associations:

- belongs_to
- has_many
- has_one
- has_and_belongs_to_many

These associations are well suited to relationships that are part
of an application's domain model and can be represented using
foreign keys or dedicated join tables.

However, some relationships are more dynamic.

For example:

- An order can reference users, products, documents, or other records.
- A record can reference different kinds of records depending
  on application logic.
- Relationships can be created and removed dynamically without
  database migrations.
- Different kinds of relationships can be managed through a common interface.
- Records can reference other records of the same model.

With conventional Rails associations, these scenarios may require
additional columns, join tables, or polymorphic associations.

*Relation* offers an alternative: a single generic table for
storing relationships between arbitrary ActiveRecord records.

## How It Works

The *relations* table contains four columns:

Column    | Description
:-------- |:---------
from_name | Model name of the source record
from_id   | ID of the source record
to_name   | Model name of the target record
to_id     | ID of the target record

Each row represents a directed relationship from one record to another.

For example:

from_name | from_id | to_name | to_id
----------|---------|---------|------
Order     | 1       | User    | 1
Order     | 1       | User    | 2
Order     | 1       | Product | 3

This means that the order with ID 1 references two users and one product.

The relationship direction is important:

~~~ruby
Relation.add order, user
~~~
establishes a relationship from order to user.

It does not automatically establish the inverse relationship.

The model names identify the corresponding ActiveRecord classes.
The record IDs identify the individual records.

A unique database index on all four columns prevents duplicate relationships.

## Installation

Add the gem to your Gemfile:

~~~ruby
gem "relation"
~~~

Install it:

~~~ruby
bundle install
~~~

Next, create the relations table.

You can copy the migration provided by the gem into
your application's migration directory or create it manually:

~~~ruby
class CreateRelations < ActiveRecord::Migration[8.0]
  def change
    create_table :relations, id: false do |t|
      t.string :from_name, null: false
      t.bigint :from_id, null: false
      t.string :to_name, null: false
      t.bigint :to_id, null: false

      t.index [:from_name, :from_id, :to_name, :to_id],
        unique: true

      t.index [:to_name, :to_id, :from_name, :from_id]
    end
  end
end
~~~

Run the migration:

~~~ruby
bin/rails db:migrate
~~~

Note: The migration version should match the Rails version used
by your application.

## Usage

Assume the application has the following ActiveRecord models:

~~~ruby
class Order   <ApplicationRecord; end
class User    <ApplicationRecord; end
class Product <ApplicationRecord; end
~~~

The examples below assume that the records have already been persisted.

### Creating relationships

Use *Relation.add* to establish a relationship between two persisted
ActiveRecord records.

~~~ruby
Relation.add order, user
Relation.add order, user2
Relation.add order, product
~~~

The first argument is the source record.
The second argument is the target record.

Relationships are directional.
In this example, the order references two users and one product.

Adding the same relationship more than once does not create duplicates.

### Finding referenced records

Use *Relation.references* to retrieve records referenced by
a particular record.                                                         â

The second argument specifies the expected target model:

~~~ruby
Relation.references order, User    # => [user, user2]
Relation.references order, Product # => [product]
~~~

The method returns an ActiveRecord relation,
so additional query conditions can be applied:

~~~ruby
Relation.references(order, User).where(active: true)
~~~

Only records of the specified model are returned.

### Finding referencing records

Use *Relation.followers* to retrieve records that reference
a particular record.

The second argument specifies the expected model class.

~~~ruby
Relation.followers user, Order  # => [order]
~~~

This method also returns an *ActiveRecord* relation
and supports additional query conditions:

~~~ruby
Relation.followers(user, Order).where(status: :active)
~~~

*references* and *followers* provide two ways to navigate
the same directed relationship.

### Removing relationships

Use *Relation.remove* to remove a relationship:

~~~ruby
Relation.remove order, user
~~~

Removing a relationship does not delete either of the associated records.

If the relationship does not exist, the operation has no effect.

### Raw API

*Relation* also provides a lower-level raw API operates directly
on model names and record IDs.

The raw API does not require the corresponding ActiveRecord records to exist.

~~~ruby
Relation.add_raw        "Order", 1, "User", 1
Relation.add_raw        "Order", 1, "User", 2
Relation.references_raw "Order", 1, "User"    # => [1, 2]
Relation.followers_raw  "Order", "User", 2    # => [1]
Relation.delete_raw     "Order", 1, "User", 2
~~~

The raw API can also be useful when relationships cannot
be represented using the polymorphic names of ActiveRecord classes.

Unlike the object API, the raw API does not validate whether
the referenced records exist.
Consequently, you are responsible for maintaining data consistency
and cleaning up dangling relationships.

The raw API is intended for situations where direct access
to relationship identifiers is necessary.

Usage of the raw API is discouraged. You should know what you are doing!

## Limitations and Considerations

*Relation* deliberately provides a much simpler abstraction than
conventional Rails associations.

There are some important differences to understand.

### No Rails association integration

*Relation* does not implement Rails association macros.

You cannot use:

~~~ruby
has_many :users
belongs_to :order
~~~

Instead, relationships are accessed explicitly through the *Relation* API.

*Relation* does not provide the additional behavior normally associated
with Rails associations, such as:

- Association proxies and collection methods.
- Automatic association loading and eager loading.
- Nested attributes.
- Association callbacks.
- Dependent destruction.
- Automatic validation of associated records.

Any additional application-level behavior must be implemented separately.

### No foreign key constraints

The *relations* table does not contain database-level foreign keys
to the associated records.

This allows relationships between arbitrary model types but means that
the database cannot enforce referential integrity.

Deleting an ActiveRecord record does not automatically remove
its relationships.

### Dangling relationships

A relationship becomes dangling when its source or target record
no longer exists.

For example, deleting a user without removing its relationships
leaves references to a nonexistent record.

*Relation* provides two methods for identifying and cleaning up
such relationships:

~~~ruby
dangling = Relation.dangling
Relation.remove_dangling dangling
~~~

The first method identify dangling references.
It returns a hash containing model names and the IDs
of records that no longer exist.

For example:

~~~ruby
{
  "User" => [3, 7],
  "Product" => [12]
}
~~~

The IDs represent records that are referenced in the relationship table
but no longer exist in their respective ActiveRecord tables.

The second method remove the corresponding relationships.

This removes relationships in which one of the specified records appears
as either the source or the target.

It does not delete any ActiveRecord records.

Note: Identifying and removing dangling relationships is
an application responsibility.
These operations are not performed automatically when records are deleted.

### Relationship direction

Relationships are directional.

~~~ruby
Relation.add order, user
~~~

does not automatically establish a relationship from user to order.

Use *Relation.followers* to navigate in the opposite direction.

### Primary keys

The object API supports integer primary keys.

Models must be named, non-abstract ActiveRecord classes with a primary key.

Records must be persisted before relationships can be created
or queried through the object API.

### Model renaming

*Relation* stores model names as strings.

Renaming an ActiveRecord model may therefore require updating
the corresponding values in the relations table.

### Database indexes

The relationship table uses two indexes:

- A unique composite index on from_name, from_id, to_name, and to_id
  prevents duplicate relationships.
- A reverse composite index on to_name, to_id, from_name, and from_id
  supports queries for records referencing a particular target.

The table deliberately has no conventional primary key.

### Bulk operations

Methods such as *delete_all* bypass ActiveRecord callbacks.

This is intentional: relationship operations work directly with
the relationship table and do not require individual model instances.

## When Should You Use Relation?

*Relation* is particularly useful when:

- Relationships are dynamic and can connect different model types.
- You need a common mechanism for managing heterogeneous relationships.
- You want to avoid association-specific columns or join tables.
- Relationships are managed independently of the associated records.
- You need to establish relationships between arbitrary
  ActiveRecord models.

It is probably not the right choice when:

- Relationships are a fundamental part of your domain model.
- Conventional foreign keys and Rails associations adequately
  describe your data.
- You depend on Rails association features such as autosaving,
  nested attributes, or dependent destruction.
- Database-level referential integrity is essential.

In short, Relation is not intended to replace conventional
Rails associations.
It provides an alternative for applications that need a generic
and flexible relationship store.

## Versions

### Version 1.0

Version 1.0.x is intended for Rails 8 and newer.

This version includes:

- Improved implementation.
- Extensive tests.
- Rewritten documentation.

#### Breaking changes:
- Relation.delete(x, y) was renamed to Relation.remove(x, y).
- Relation.followers(Order, user) changed to Relation.followers(user, Order).

### Version 0.5

Version 0.5.* is intended for Rails 8.

### Version 0.4

Version 0.4.* is intended for Rails 7.

### Rails 6

This gem is intended for Rails 6.
Rails 5 should work fine.

Older Rails versions may use "gem 'relation', '= 0.1.1'".

## License

Copyright (c) 2015-2026 Dittmar Krall.

Released under the [MIT license](https://opensource.org/licenses/MIT).
