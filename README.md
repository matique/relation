# Relation
[![Build Status](http://img.shields.io/travis/matique/relation.svg)](https://travis-ci.org/matique/relation)
[![Dependency Status](http://img.shields.io/gemnasium/matique/relation.svg)](https://gemnasium.com/matique/relation)
[![Gem Version](http://img.shields.io/gem/v/relation.svg)](https://rubygems.org/gems/relation)

Relation is a Rails gem that adds relationships to
ActiveRecord items stored in tables.
The relationship is stored in an additional table;
no additional column/field is required in the particular tables.

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

    $ [sudo] gem install relation

or:

    # Gemfile file
    gem 'relation'

    $ bundle

Furthermore the association table (an n-ways-join table) must be
installed and migrated.
You may copy the migration "db/migrate/20150810152808_relation.rb"
from the gem.
The migration is then done, as usual, by:

    $ rails db:migrate

## Usage

In short (order* and user* are ActiveRecords):

    Relation.add order, user
    Relation.add order, user2
    Relation.add order2, user2

    Relation.references order, User   # -> [user, user2]
    Relation.references order2, User  # -> [user2]
    Relation.followers  Order, user   # -> [order]
    Relation.followers  Order, user2  # -> [order, order2]

    Relation.delete     order2, user2
    Relation.followers  Order, user2  # -> [order]

See also the tests.

Dangling, i.e. inaccessible records, references are detected by:

    hsh = Relation.dangling

and cleaned by:

    Relation.remove_dangling hsh

Rails 5
-------

This gem is intended for Rails 5.
Older Rails versions may use "gem 'relation', '= 0.1.1'".

License MIT
-----------
