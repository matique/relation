# frozen_string_literal: true

class Relation < ActiveRecord::Base
  def self.add_raw(name, from_id, to_id)
    hsh = {name: name, from_id: from_id, to_id: to_id}
    Relation.create!(hsh) if Relation.where(hsh).first.nil?
  end

  def self.delete_raw(name, from_id, to_id)
    hsh = {name: name, from_id: from_id, to_id: to_id}
    Relation.where(hsh).delete_all
  end

  def self.references_raw(name, from_id)
    Relation.where(name: name, from_id: from_id).pluck(:to_id)
  end

  def self.followers_raw(name, to_id)
    Relation.where(name: name, to_id: to_id).pluck(:from_id)
  end

  # extended Relation: extracts relation from rows
  def self.add(row_from, row_to)
    hsh = normalize(row_from, row_to)
    Relation.create!(hsh) if Relation.where(hsh).first.nil?
  end

  def self.delete(row_from, row_to)
    hsh = normalize(row_from, row_to)
    Relation.where(hsh).delete_all
  end

  def self.references(row, kind)
    klass, name, from_id = normalize2(kind, row)
    name = "#{name} #{klass.name}"
    ids = references_raw(name, from_id)
    klass.where(id: ids)
  end

  def self.followers(kind, row)
    klass, name, to_id = normalize2(kind, row)
    name = "#{klass.name} #{name}"
    ids = followers_raw(name, to_id)
    klass.where(id: ids)
  end

  def self.name_id(resource)
    raise "missing resource" unless resource

    [resource.class.name, resource.id]
  end

  def self.normalize(row_from, row_to)
    name_from, from_id = name_id(row_from)
    name_to, to_id = name_id(row_to)
    name = "#{name_from} #{name_to}"
    {name: name, from_id: from_id, to_id: to_id}
  end

  def self.normalize2(kind, row)
    klass = kind
    klass = kind.constantize unless klass.is_a?(Class)
    name, id = name_id(row)
    [klass, name, id]
  end

  # dangling relations
  def self.dangling
    names = Relation.pluck(:name).uniq
    models = []
    names.each { |name| models |= name.split(" ") }
    hsh = {}
    models.each do |class_name|
      klass = class_name.constantize
      ids = klass.pluck(:id)
      idx = Relation.where("name like ?", "#{class_name} %").pluck(:from_id)
      idy = Relation.where("name like ?", "% #{class_name}").pluck(:to_id)
      arr = (idx | idy) - ids
      hsh[class_name] = arr if arr.length.positive?
    end
    hsh
  end

  def self.remove_dangling(hsh)
    hsh.each do |name, arr|
      arr.each do |idx|
        Relation.where(from_id: idx).where("name like ?", "#{name} %").delete_all
        Relation.where(to_id: idx).where("name like ?", "% #{name}").delete_all
      end
    end
  end
end
