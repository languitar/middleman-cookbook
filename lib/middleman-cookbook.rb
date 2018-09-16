require 'middleman-core'

Middleman::Extensions.register :middleman_cookbook do
  require 'middleman-cookbook/extension'
  ::Middleman::Cookbook::Cookbook
end
