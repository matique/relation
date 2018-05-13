module ModRelation
  class Engine < Rails::Engine
    isolate_namespace ModRelation

# # https://github.com/rails/rails/issues/22261
# p 11111111111111111111111
#     initializer :append_migrations do |app|
# #p [10, app]
# p 10
#       config.paths['db/migrate'].expanded.each do |path|
# p [12, path]
#         app.config.paths['db/migrate'] << path
# p 13
#         ActiveRecord::Migrator.migrations_paths << path
# p [14, ActiveRecord::Migrator.migrations_paths]
#       end
#     end

  end
end


# # https://github.com/rails/rails/issues/22261
# module ActiveRecord
# #module ActiveRecord::Current
#   class Schema < Migration
#     def migrations_paths
#       (ActiveRecord::Migrator.migrations_paths + Rails.application.paths['db/migrate'].to_a).uniq
#     end
#   end
# end
