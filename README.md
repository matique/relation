# Relation
[!Build Status](https://secure.travis-ci.org/amerine/relation.svg?branch=master)](http://travis-ci.org/amerine/connection)
[!Gem Version](https://badge.fury.io/rb/relation.svg)](http://badge.fury.io/rb/connection)

Relation is a Rails gem that adds relationships to
ActiveRecord items stored in tables.
It uses an additional table to store the relations,
i.e. no additional column/field is required in the tables.

A habtm association of Rails requires an additional table
containing the id's of the associated records.
The name of the table indicates which tables are being related.
Relation just move the name of the association table into an additional
column enabling relationship between any AR,
but loosing the magic of Rails for associations.


## Example


http://blog.hasmanythrough.com/2006/4/20/many-to-many-dance-off

n-ways-join table

Join models have primary keys, just like every other model. This means
you can access and manipulate records directly.

Here's the table for the built-in Relationship model:

create_table :relationships do |t|
  t.references :parent, :polymorphic => true
  t.references :child, :polymorphic => true
  t.string :context
  t.string :value
  t.integer :position
  t.timestamps
end

The features are:


    Double sided polymorphic associations. Which means you can tie any object to any other object.
    Built-in relationship directionality, similar to a Directed Acyclic Graph. So you can say the Post is parent of Image, since you usually attach an Image to a Post (not the other way around), so Image is child of Post. This means you have some sort of built in hierarchy.
    Context. You can create many-to-many relationships between the same models and call them different things. This is roughly equivalent to creating STI join models. This is useful for creating something like organizing Users of a Group into Roles.
    Position. You can sort the objects by relationship in primitive ways.

Installation

It's a gem - so you can either install it yourself, or add it to the appropriate Gemfile or gemspec.

gem install joiner --version 0.3.4

Usage

Installation

Add this line to your application's Gemfile:

gem 'active_record-acts_as'

And then execute:

$ bundle

Or install it yourself as:

$ gem install active_record-acts_as
