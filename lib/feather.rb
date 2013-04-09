module Feather
  # == Submodules ===========================================================

  autoload(:Support, 'feather/support')
  autoload(:Template, 'feather/template')

  # == Module Methods =======================================================

  # Returns the current library version
  def self.version
    @version ||= File.readlines(
      File.expand_path('../VERSION', File.dirname(__FILE__))
  ).first.chomp
  end

  # Create a new template with a supplied template body and optional options.
  def self.new(*args)
    template = Feather::Template.new(*args)

    yield(template) if (block_given?)

    template
  end
end
