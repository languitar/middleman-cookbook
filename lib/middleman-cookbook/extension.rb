# Require core library
require 'middleman-core'

module Middleman
  module Cookbook
    module Recipe
      def self.extended(base)
        base.class.send(:attr_accessor, :controller)
        base.class.send(:attr_accessor, :recipe_data)
      end

      def render(opts={}, locs={}, &block)

        unless opts.key?(:layout)
          opts[:layout] = metadata[:options][:layout]
          opts[:layout] = controller.options.layout if opts[:layout].nil? || opts[:layout] == :_auto_layout

          # Convert to a string unless it's a boolean
          opts[:layout] = opts[:layout].to_s if opts[:layout].is_a? Symbol
        end

        print("#{opts}\n")

        content = super(opts, locs, &block)

        content
      end
    end

    class RecipeDatabase
      def initialize(app, controller, options)
        @app        = app
        @controller = controller
        @options    = options

        # prepare schema validator
        @schemer = JSONSchemer.schema(
          Pathname.new(File.join(File.dirname(__FILE__), 'schema.json'))
        )
      end

      def load_recipe(resource)
        yaml = YAML.safe_load(resource.render(layout: false))
        errors = @schemer.validate(yaml)
        raise ArgumentError, "YAML validation error: #{errors.to_a}" if errors.any?
        yaml
      end

      def manipulate_resource_list(resources)

        used_resources = []

        print("Recipe dir: #{@options.recipe_dir}\n")
        recipe_dir = @options.recipe_dir.split(File::SEPARATOR)

        resources.each do |resource|
          if resource.ignored?
            used_resources << resource
            next
          end

          print("Resource #{resource}\n")
          print("  path #{resource.path}\n")
          directory = File.dirname(resource.path).split(File::SEPARATOR)
          if directory.take(recipe_dir.size) == recipe_dir
            begin
              print("  is recipe\n")
              recipe_data = load_recipe(resource)
              print("  #{recipe_data}\n")
              resource = convert_to_recipe(resource)
              resource.data.title = recipe_data['name']
              resource.recipe_data = recipe_data
              resource.destination_path = File.join(
                File.dirname(resource.path),
                File.basename(resource.path, '.*') + '.html'
              )
            rescue Psych::SyntaxError, ArgumentError => error
              warn "YAML parsing error for recipe #{resource.path}: #{error.message}"
              exit 1
            end
          end

          used_resources << resource
        end

        used_resources
      end

      def convert_to_recipe(resource)
        return resource if resource.is_a?(Recipe)

        resource.extend Recipe
        resource.controller = @controller

        resource
      end
    end

    class Cookbook < ::Middleman::Extension
      option :recipe_dir, 'recipes', 'Directory containing the YAML-formatted recipes'
      option :layout, 'layout', 'Recipe layout'

      def initialize(app, options_hash={}, &block)
        # Call super to build options from the options_hash
        super

        # Require libraries only when activated
        require 'json_schemer'
        require 'pathname'
        require 'yaml'

      end

      def after_configuration
        @data = RecipeDatabase.new(@app, self, options)
        @app.sitemap.register_resource_list_manipulator(:recipes, @data)
      end

      # A Sitemap Manipulator
      # def manipulate_resource_list(resources)
      #
      #   Dir.children(options.recipe_dir).each do |recipe_file|
      #     print recipe_file
      #
      #     next if File.extname(recipe_file) != '.yml'
      #
      #     resources.push Middleman::Cookbook::RecipeResource.new(
      #       @app.sitemap, recipe_file, @options
      #     )
      #   end
      #
      #   resources
      # end

      # helpers do
      #   def a_helper
      #   end
      # end
    end
  end
end
