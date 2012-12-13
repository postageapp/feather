module Feather
  # == Submodules ===========================================================

  autoload(:Support, 'feather/support')
  autoload(:Template, 'feather/template')

  def self.version
    @version ||= File.readlines(
      File.expand_path('../VERSION', File.dirname(__FILE__))
  ).first.chomp
  end

  def self.new(*args)
    template = Feather::Template.new(*args)

    yield(template) if (block_given?)

    template
  end
end
