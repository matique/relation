class Relation < ActiveRecord::Base

  def self.add_raw(name, id_from, id_to)
    hsh = { name: name, x_id: id_from, y_id: id_to }
    Relation.create!(hsh)  if Relation.where(hsh).first == nil
  end

  def self.delete_raw(name, id_from, id_to)
    hsh = { name: name, x_id: id_from, y_id: id_to }
    Relation.where(hsh).delete_all
  end

  def self.references_raw(name, id_from)
    ids = self.referenced_ids_raw(name, id_from)
  end

  def self.followers_raw(name, id_to)
    ids = self.followers_ids_raw(name, id_to)
  end


 private
  def self.referenced_ids_raw(name, id_from)
    Relation.where(name: name, x_id: id_from).pluck(:y_id)
  end

  def self.followers_ids_raw(name, id_to)
    Relation.where(name: name, y_id: id_to).pluck(:x_id)
  end

end
