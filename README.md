# Relation
[![Build Status](https://travis-ci.org/matique/relation.svg?branch=master)](https://travis-ci.org/matique/relation)
[![Build Status](http://img.shields.io/travis/matique/relation.svg)](https://travis-ci.org/matique/relation)
[![Dependency Status](http://img.shields.io/gemnasium/matique/relation.svg)](https://gemnasium.com/matique/relation)
[![Code Climate](http://img.shields.io/codeclimate/github/matique/relation.svg)](https://codeclimate.com/github/matique/relation)
[![Gem Version](http://img.shields.io/gem/v/relation.svg)](https://rubygems.org/gems/relation)
[![Badges](http://img.shields.io/:badges-5/5-ff6799.svg)](https://github.com/badges/badgerbadgerbadger)

Relation is a Rails gem that adds relationships to
ActiveRecord items stored in tables.
The relationship is stored in an additional table;
no additional column/field is required in the tables.

A habtm (has and belong to many) association of Rails requires an
additional table containing the id's of the associated records.
The name of this table indicates which tables are being associated.
Relation just move the name of the association table into an additional
column enabling relationship between any ActiveRecords.

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

    $ rake db:migrate

## Usage

In short (product* and category* are ActiveRecords):

    Relation.add product, category
    Relation.add product, category2
    Relation.add product2, category2

    Relation.find product, Category   # -> [category, category2]
    Relation.find product2, Category  # -> [category2]
    Relation.find Product, category   # -> [product]
    Relation.find Product, category2  # -> [product, product2]

    Relation.delete product2, category2
    Relation.find Product, category2  # -> [product]

See also the tests.

Dangling references are detected by:

    hsh = Relation.dangling

and cleaned by:

    Relation.remove_dangling hsh

## License

Copyright (c) 2015 [Dittmar Krall], released under the MIT license.
