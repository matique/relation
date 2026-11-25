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
<-------- |<---------
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

















AFAIK, Relation can replace all kind of relationships in a Rails database.
The gem stores the relationships in a additional table (named
"relations") containing
triples (name of relationship, from_id, to_id).
No additional column/field is required in a particular table.
Adding/removing a relationship do not required a migration.

Is it recommendable? Well, you should know.
In particular, the automagic of Rails associations is not available
for this gem.

A habtm (has and belong to many) association of Rails requires an
additional table containing the id's of the associated records.
The name of this table indicates which tables are being associated.

Relation just move the name of the association table into an additional
column enabling relationship between any ActiveRecords in any,
including themselves, tables.

Rails furthermore adds some "magic" to the habtm like additional methods
and administration of the association table.
These additions are not supported by Relation,
i.e. you are responsible for them.

## Installation

As usual:
``` ruby
# Gemfile
gem "relation"
```
and run "bundle install".

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

Use Relation.add to establish a relationship between two persisted
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
Relation.followers Order, user  # => [order]
~~~

This method also returns an *ActiveRecord* relation.

### Removing relationships

Use Relation.remove to remove a relationship:
~~~ruby
Relation.remove order, user
~~~

Removing a relationship does not delete either of the associated records.


Raw API

The object API derives model names and record IDs from ActiveRecord
instances.




































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

See also the tests.

Dangling, i.e. inaccessible records, references are detected by:

    hsh = Relation.dangling

and cleaned by:

    Relation.remove_dangling hsh

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

## Version 0.5

Version 0.5.* is intended for Rails 8.

## Version 0.4

Version 0.4.* is intended for Rails 7.

## Rails 6

This gem is intended for Rails 6.
Rails 5 should work fine.

Older Rails versions may use "gem 'relation', '= 0.1.1'".

## Miscellaneous

Copyright (c) 2015-2026 Dittmar Krall (www.matiq.com),
released under the [MIT license](https://opensource.org/licenses/MIT).
