# Relation

[![Gem Version](https://img.shields.io/gem/v/relation?color=168AFE&logo=rubygems&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![Downloads](https://img.shields.io/gem/dt/relation?color=168AFE&logo=rubygems&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![GitHub Build](https://img.shields.io/github/actions/workflow/status/matique/relation/rake.yml?logo=github)](https://github.com/matique/relation/actions/workflows/rake.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-168AFE.svg)](https://github.com/standardrb/standard)
[![MIT License](https://img.shields.io/badge/license-MIT-168AFE.svg)](http://choosealicense.com/licenses/mit/)

**Relation** provides a generic way to establish relationships
between arbitrary ActiveRecord records without modifying
their respective database tables.

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

## Installation

Add the gem to your Gemfile:

~~~ruby
gem "relation"
~~~

Install it:

~~~ruby
bundle install
~~~

Create the `relations` table using the migration provided by the gem
or create it manually:

~~~ruby
class CreateRelations < ActiveRecord::Migration[8.0]
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

Assume the following ActiveRecord models:

~~~ruby
class Order < ApplicationRecord; end
class User < ApplicationRecord; end
class Product < ApplicationRecord; end
~~~

All records must be persisted before using the object API.

### Creating relationships

Use `Relation.add` to establish a directed relationship:

~~~ruby
Relation.add order, user
Relation.add order, user2
Relation.add order, product
~~~

The first argument is the source record and the second is the target record.
Adding the same relationship multiple times does not create duplicates.

### Finding related records

Use `Relation.references` to retrieve records referenced by
a particular record.

~~~ruby
Relation.references order, User    # => [user, user2]
Relation.references order, Product # => [product]
~~~

Use `Relation.followers` to retrieve records that reference
a particular record:

~~~ruby
Relation.followers user, Order # => [order]
~~~

Both methods return ActiveRecord relations,
allowing additional query conditions:

~~~ruby
Relation.references(order, User).where(active: true)
Relation.followers(user, Order).where(status: :active)
~~~

### Removing relationships

Use `Relation.remove` to remove a relationship:

~~~ruby
Relation.remove order, user
~~~

Removing a relationship does not delete either record.
If the relationship does not exist, nothing happens.

### Raw API

The raw API operates directly on model names and record IDs,
without requiring the corresponding ActiveRecord records to exist.

~~~ruby
Relation.add_raw        "Order", 1, "User", 1
Relation.add_raw        "Order", 1, "User", 2

Relation.references_raw "Order", 1, "User"    # => [1, 2]
Relation.followers_raw  "Order", "User", 2    # => [1]

Relation.remove_raw     "Order", 1, "User", 2
~~~

The raw API uses `Relation.remove_raw` to delete relationships
by model names and IDs,
while the object API uses `Relation.remove` to delete relationships
between ActiveRecord instances.

Unlike the object API, the raw API does not verify
whether referenced records exist.
You are responsible for maintaining data consistency.

## Limitations

**Relation** provides a simpler abstraction than
conventional Rails associations.

- No association macros, proxies, or callbacks.
- No automatic association loading or eager loading.
- No nested attributes or dependent destruction.
- No database-level foreign key constraints.
- Only integer primary keys are supported by the object API.
- Model renaming may require updating stored model names.
- Bulk operations bypass ActiveRecord callbacks.
- The relationship table has no conventional primary key.

The application is responsible for maintaining referential integrity.

### Dangling relationships

A relationship is dangling when either its source or target
record no longer exists.

Use `Relation.dangling` to identify dangling relationships:

~~~ruby
Relation.dangling
# => {
#    "User" => [3, 7],
#    "Product" => [12]
# }
~~~

Returns a hash mapping model names to IDs of records that no longer exist
but are still involved in stored relationships.

Use `Relation.remove_dangling` to remove relationships
involving missing records:

~~~ruby
Relation.remove_dangling(Relation.dangling)
~~~

Cleanup is not performed automatically
and remains the application's responsibility.

## Compatibility

Version | Rails
:------ |:-------
1.0.x   | 8+
0.5.x   | 8
0.4.x   | 7
0.1.1   | Older versions

Version 1.0 introduces the following breaking changes:

- `Relation.delete(x, y)` was renamed to `Relation.remove(x, y)`.
- `Relation.delete_raw(x, y)` was renamed to `Relation.remove_raw(x, y)`.
- `Relation.followers(Order, user)` changed
  to `Relation.followers(user, Order)`.

## License

Copyright (c) 2015-2026 Dittmar Krall.

Released under the [MIT license](https://opensource.org/licenses/MIT).
