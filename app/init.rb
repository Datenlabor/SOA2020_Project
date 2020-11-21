# frozen_string_literal: true

folders = %w[domain controllers infrastructure presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
