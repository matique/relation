class Relation < ActiveRecord::Base

  def self.add_raw(name, id_from, id_to, position = 0)
    hsh = { name: name, from_id: id_from, to_id: id_to, position: position }
    Relation.create!(hsh)  if Relation.where(hsh).first == nil
  end

  def self.delete_raw(name, id_from, id_to)
    hsh = { name: name, from_id: id_from, to_id: id_to }
    Relation.where(hsh).delete_all
  end

  def self.references_raw(name, id_from)
    Relation.where(name: name, from_id: id_from).pluck(:to_id)
  end

  def self.followers_raw(name, id_to)
    Relation.where(name: name, to_id: id_to).pluck(:from_id)
  end

end
