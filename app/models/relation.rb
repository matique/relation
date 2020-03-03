class Relation < ActiveRecord::Base
  def self.add_raw(name, from_id, to_id)
    hsh = { name: name, from_id: from_id, to_id: to_id }
    Relation.create!(hsh) if Relation.where(hsh).first.nil?
  end

  def self.delete_raw(name, from_id, to_id)
    hsh = { name: name, from_id: from_id, to_id: to_id }
    Relation.where(hsh).delete_all
  end

  def self.references_raw(name, from_id)
    Relation.where(name: name, from_id: from_id).pluck(:to_id)
  end

  def self.followers_raw(name, to_id)
    Relation.where(name: name, to_id: to_id).pluck(:from_id)
  end
end
