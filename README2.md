# Relation

[![Gem Version](https://img.shields.io/gem/v/relation?color=168AFE&logo=rubygems&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![Downloads](https://img.shields.io/gem/dt/relation?color=168AFE&logo=rubygems&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![GitHub Build](https://img.shields.io/github/actions/workflow/status/matique/relation/rake.yml?logo=github)](https://github.com/matique/relation/actions/workflows/rake.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-168AFE.svg)](https://github.com/standardrb/standard)
[![MIT License](https://img.shields.io/badge/license-MIT-168AFE.svg)](http://choosealicense.com/licenses/mit/)

*Relation* allows you to establish relationships between arbitrary
ActiveRecord records without adding foreign keys, association columns,
or dedicated join tables to their respective database tables.

All relationships are stored in one additional database table.

~~~ruby
Relation.add order, user
Relation.add order, product
Relation.add order, another_user

Relation.references order, User    # => [user, another_user]
Relation.references order, Product # => [product]
Relation.followers  user,  Order   # => [order]
~~~

This makes it possible to organize relationships between different models,
including relationships between records of the same model.

## Why Relation?

Rails provides excellent support for conventional database associations:

- belongs_to
- has_many
- has_one
- has_and_belongs_to_many

These associations work particularly well when relationships are part
of the application's domain model and can be represented
by foreign keys or dedicated join tables.

However, sometimes relationships are more dynamic.

For example:

- An order can reference users, products, documents, or other records
- A record can reference different kinds of records depending on
  application logic
- Relationships can be created and removed dynamically without
  database migrations
- Different kinds of relationships can be managed through a common interface
- A model can reference records of its own type.

With conventional Rails associations, these scenarios may require
additional columns, join tables, or polymorphic associations.

*Relation* offers another approach: store all relationships in one
generic table.

## How It Works

The *relations* table contains four columns:

Column    | Description
:-------- |:---------
from_name | Model name of the source record
from_id   | ID of the source record
to_name   | Model name of the target record
to_id     | ID of the target record

A relationship is therefore represented by a pair of model names
and record IDs.

For example:

from_name | from_id | to_name | to_id
----------|---------|---------|------
Order     | 1       | User    | 1
Order     | 1       | User    | 2
Order     | 1       | Product | 3

The model names identify the respective ActiveRecord classes.

Consequently, no additional columns or association tables are required
in the individual model tables.

The relationship table has a unique index on all four columns to prevent
duplicate relationships.

## Is it recommendable?

Well, you should know!

In particular, the automagic of Rails associations is not available
for this gem.

A habtm (has and belong to many) association of Rails requires an
additional table containing the id's of the associated records.
The name of this table indicates which tables are being associated.

*Relation* requires just one table for all the relationships.

Rails furthermore adds some "magic" to the habtm like additional methods
and administration of the association table.
These additions are not supported by *Relation*,
i.e. you are responsible for them!

## Installation

As usual:
~~~ruby
# Gemfile
gem "relation"
~~~
Then run:

    $ bundle install

Next, install the relations table.

You can copy the migration provided by the gem
(db/migrate/003_create_relations.rb)
into your application's migration directory.

Alternatively, create the table with the following migration:

~~~ruby
create_table :relations, id: false do |t|
  t.string :from_name, null: false
  t.bigint :from_id, null: false
  t.string :to_name, null: false
  t.bigint :to_id, null: false

  t.index [:from_name, :from_id, :to_name, :to_id], unique: true
  t.index [:to_name, :to_id, :from_name, :from_id]
end
~~~

Run the migration:

    $ rails db:migrate

## Usage

Assume the application has the following ActiveRecord models:

~~~ruby
class Order   <ApplicationRecord; end
class User    <ApplicationRecord; end
class Product <ApplicationRecord; end
~~~

### Creating relationships

Use *Relation.add* to establish a relationship between two persisted
ActiveRecord records.

~~~ruby
Relation.add order, user
Relation.add order, user2
Relation.add order, product
~~~

Relationships are directional.

In the examples above, the order references the users and product.

Adding the same relationship more than once does not create duplicates.

### Finding referenced records

Use *Relation.references* to retrieve records referenced by another record.

The second argument specifies the expected model class.

~~~ruby
Relation.references order, User    # => [user, user2]
Relation.references order, Product # => [product]
~~~

The result is an ActiveRecord relation, so additional query conditions
can be applied:

~~~ruby
Relation.references(order, User).where(active: true)
~~~

### Finding referencing records

Use *Relation.followers* to retrieve records referencing a particular record.

The second argument specifies the expected model class.

~~~ruby
Relation.followers user, Order  # => [order]
~~~

This method also returns an *ActiveRecord* relation.

### Removing relationships

Use *Relation.remove* to remove a relationship:

~~~ruby
Relation.remove order, user
~~~

Removing a relationship does not delete either of the associated records.

### Raw API

*Relation* also provides a lower-level raw API.

The raw API operates directly on model names and record IDs.

~~~ruby
Relation.add_raw        "Order", 1, "User", 1
Relation.add_raw        "Order", 1, "User", 2
Relation.references_raw "Order", 1, "User"  # => [1, 2]
Relation.followers_raw  "Order", "User", 2  # => [1]
Relation.delete_raw     "Order", 1, "User", 2
~~~

The raw API does not require the corresponding ActiveRecord records to exist.
Consequently, dangling references must be handled by the application.

Usage of the raw API is discouraged. You should know what you are doing!

## Usage

In short (order* and user* are instances of ActiveRecords):

``` ruby
Relation.add order, user
Relation.add order, user2
Relation.add order2, user2

Relation.references order, User   # -> [user, user2]
Relation.references order2, User  # -> [user2]
Relation.followers  Order, user   # -> [order]
Relation.followers  Order, user2  # -> [order, order2]

Relation.delete     order2, user2
Relation.followers  Order, user2  # -> [order]
```

## Limitations and Considerations

*Relation* deliberately provides a much simpler abstraction than
Rails associations.
There are some important differences.

### No Rails association magic

*Relation* does not implement Rails association macros.

You cannot use:
~~~ruby
has_many :users
belongs_to :order
~~~

Instead, relationships are accessed explicitly through the *Relation* API.

You are responsible for implementing any additional application-level
behavior, such as validations, callbacks, dependent deletion,
or association administration.

### No foreign key constraints

The relationship table does not contain database-level foreign keys
to the associated records.

This makes relationships flexible but also means that deleting
an ActiveRecord record does not automatically remove its relationships.

### Dangling references

A relationship can become dangling when one of its associated records
is deleted.

Dangling, i.e. inaccessible records, references are identified by:

    hsh = Relation.dangling

and cleaned by:

    Relation.remove_dangling hsh

### No referential integrity guarantees

The application is responsible for maintaining the consistency of
relationships.

In particular, the database cannot guarantee that every referenced
record exists.

### Relationship direction

Relationships are directional.

~~~ruby
Relation.add order, user
~~~

does not automatically establish the inverse relationship.

Use *Relation.followers* to navigate in the opposite direction.

### When Should You Use Relation?

*Relation* is particularly useful when:

- Relationships are dynamic and can connect different model types.
- You want a common mechanism for storing heterogeneous relationships.
- You want to avoid adding association-specific columns or join tables.
- Relationships are managed independently of the associated records.
- You need to establish relationships between records of arbitrary
  ActiveRecord models.

It is probably not the right choice when:

- Relationships are a fundamental part of your domain model
- Conventional foreign keys and Rails associations adequately describe
  your data
- You depend on Rails association features such as autosaving,
  nested attributes, or dependent destruction
- Database-level referential integrity is essential

In short: *Relation* is not intended to replace conventional Rails
associations. It provides an alternative for applications that need
a generic, flexible relationship store.

## Low Level Methods

Above mentioned methods are based on the following low level methods:

``` ruby
Relation.add_raw(name, from_id, to_id)
Relation.delete_raw(name, from_id, to_id)
Relation.references_raw(name, from_id)
Relation.followers_raw(name, to_id)
```

They may be used for relationships which can not be based on the
class name of the ActiveRecords.
Keep in mind that dangling relations must be handled by yourself.


## Versions
### Version 1.0

Version 1.0.* is intended for Rails 8.+.

This version has been improved with extensive tests.

The documentation was rewritten.

### Version 0.5

Version 0.5.* is intended for Rails 8.

### Version 0.4

Version 0.4.* is intended for Rails 7.

### Rails 6

This gem is intended for Rails 6.
Rails 5 should work fine.

Older Rails versions may use "gem 'relation', '= 0.1.1'".

## Miscellaneous

Copyright (c) 2015-2026 Dittmar Krall (www.matiq.com),
released under the [MIT license](https://opensource.org/licenses/MIT).
