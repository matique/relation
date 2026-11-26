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

Rails associations such as belongs_to, has_many,
and has_and_belongs_to_many work well for relationships
that are part of an application's domain model.

However, some relationships are more dynamic:

- An order can reference users, products, documents, or other records.
- A record can reference different kinds of records.
- Relationships can be created and removed without database migrations.
- Different model types can share a common relationship mechanism.
- Records can reference other records of the same model.

Relation provides an alternative: a single generic table
for storing relationships between arbitrary ActiveRecord records.

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

The order with ID 1 references two users and one product.

Relationships are directional:

~~~ruby
Relation.add order, user
~~~
establishes a relationship from order to user.
It does not automatically establish the inverse relationship.

A unique composite index prevents duplicate relationships.
A second index supports queries in the opposite direction.

## Installation

Add the gem to your Gemfile:

~~~ruby
gem "relation"
~~~

Install it:

~~~ruby
bundle install
~~~

Create the relations table using the migration provided by the gem
or create it manually:

~~~ruby
class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations, id: false do |t|
      t.string :from_name, null: false
      t.bigint :from_id, null: false
      t.string :to_name, null: false
      t.bigint :to_id, null: false

      t.index [:from_name, :from_id, :to_name, :to_id], unique: true
      t.index [:to_name, :to_id, :from_name, :from_id]
    end
  end
end
~~~

Run the migration:

~~~ruby
bin/rails db:migrate
~~~

Use the migration version matching your Rails version.

## Usage

Assume the application has the following ActiveRecord models:

~~~ruby
class Order <ApplicationRecord; end
class User <ApplicationRecord; end
class Product <ApplicationRecord; end
~~~

All records must be persisted before using the object API.

### Creating relationships

Use *Relation.add* to establish a relationship between two records:

~~~ruby
Relation.add order, user
Relation.add order, user2
Relation.add order, product
~~~

The first argument is the source record and the second is the target record.

Adding the same relationship more than once does not create duplicates.

### Finding referenced records

Use *Relation.references* to retrieve records referenced by
a particular record.

The second argument specifies the expected target model:

~~~ruby
Relation.references order, User    # => [user, user2]
~~~

Use *Relation.followers* to retrieve records referencing a particular record.

The second argument specifies the source model:

~~~ruby
Relation.followers user, Order     # => [order]
Relation.references order, Product # => [product]
Relation.references(order, User).where(active: true)
~~~

Both methods return ActiveRecord relations,
allowing additional query conditions:

~~~ruby
Relation.references(order, User).where(active: true)
Relation.followers(user, Order).where(status: :active)
~~~

### Removing relationships

Use *Relation.remove* to remove a relationship:

~~~ruby
Relation.remove order, user
~~~

Removing a relationship does not delete either record.
If the relationship does not exist, nothing happens.

### Raw API

*Relation* also provides a lower-level API that operates directly
on model names and record IDs.

The raw API does not require the corresponding ActiveRecord records to exist.

~~~ruby
Relation.add_raw        "Order", 1, "User", 1
Relation.add_raw        "Order", 1, "User", 2

Relation.references_raw "Order", 1, "User"    # => [1, 2]
Relation.followers_raw  "Order", "User", 2    # => [1]

Relation.delete_raw     "Order", 1, "User", 2
~~~

The raw API is useful when relationships cannot be represented
using ActiveRecord model names.

Unlike the object API, it does not validate whether
the referenced records exist.

Use it with care. You are responsible for maintaining data consistency
and cleaning up dangling relationships.

Usage of the raw API is discouraged. You should know what you are doing!

## Limitations

*Relation* deliberately provides a much simpler abstraction than
conventional Rails associations.

Important limitations include:

- No Rails association macros, proxies, or callbacks.
- No automatic association loading or eager loading.
- No nested attributes or dependent destruction.
- No database-level foreign key constraints.
- Only integer primary keys are supported.
- Model renaming may require updating stored model names.
- Bulk operations bypass ActiveRecord callbacks.
- The relationship table has no conventional primary key.

The application is responsible for maintaining referential integrity.

### Dangling relationships

A relationship becomes dangling when its source or target record
no longer exists.

Use Relation.dangling to identify such relationships:

~~~ruby
dangling = Relation.dangling
# => {
#    "User" => [3, 7],
#    "Product" => [12]
# }
~~~

The result contains model names and IDs of records that
are referenced but no longer exist.

Use *Relation.remove_dangling* to remove the corresponding relationships:

~~~ruby
Relation.remove_dangling(Relation.dangling)
~~~

This removes relationships involving the missing records.
It does not delete any ActiveRecord records.

Only model names resolving to valid ActiveRecord models
are considered by Relation.dangling.

Dangling relationship cleanup is an application responsibility
and is not performed automatically.

## Compatibility

Version | Rails
:------ |:-------
1.0.x   | 8+
0.5.x   | 8
0.4.x   | 7
0.1.1   | Older versions

Version 1.0 introduces the following breaking changes:

- Relation.delete(x, y) was renamed to Relation.remove(x, y).
- Relation.followers(Order, user) changed to Relation.followers(user, Order).

## License

Copyright (c) 2015-2026 Dittmar Krall.

Released under the [MIT license](https://opensource.org/licenses/MIT).
