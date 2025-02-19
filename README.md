# Relation
[![Gem Version](https://badge.fury.io/rb/relation.svg)](http://badge.fury.io/rb/relation)
[![GEM Downloads](https://img.shields.io/gem/dt/relation?color=168AFE&logo=ruby&logoColor=FE1616)](https://rubygems.org/gems/relation)
[![rake](https://github.com/matique/relation/actions/workflows/rake.yml/badge.svg)](https://github.com/matique/relation/actions/workflows/rake.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](http://choosealicense.com/licenses/mit/)

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

Furthermore the association table (an n-ways-join table) must be
installed and migrated.
You may copy the migration "./db/migrate/003_create_relations.rb"
from the gem.
Add indexes if required (benchmarking give clues).
The migration is then done, as usual, by:

    $ rails db:migrate

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

## Version 0.4

Version 0.4.* is intended for Rails 7.

## Rails 6

This gem is intended for Rails 6.
Rails 5 should work fine.

Older Rails versions may use "gem 'relation', '= 0.1.1'".

## Miscellaneous

Copyright (c) 2015-2024 Dittmar Krall (www.matiq.com),
released under the [MIT license](https://opensource.org/licenses/MIT).
