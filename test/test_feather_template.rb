require_relative './helper'

require 'yaml'

class TestFeatherTemplate < MiniTest::Test
  def test_empty_template
    template = Feather::Template.new('')
    
    assert_equal '', template.render
  end

  def test_simple_templates
    template = Feather::Template.new('example')
    
    assert_equal 'example', template.render

    template = Feather::Template.new('{{{example}}}')
    
    assert_equal '{{example}}', template.render
    
    template = Feather::Template.new('example {{example}} text')
    
    assert_equal 'example something text', template.render(:example => 'something')

    template = Feather::Template.new('example {{  example  }} text')
    
    assert_equal 'example something text', template.render(:example => 'something')
  end

  def test_repeated_rendering
    template = Feather::Template.new('example')
    
    assert_equal 'example', template.render
    assert_equal 'example', template.render
  end
  
  def test_boolean_templates
    template = Feather::Template.new('{{?boolean}}true {{/}}false')
    
    assert_equal 'false', template.render
    assert_equal 'true false', template.render(:boolean => true)
    assert_equal 'false', template.render(:boolean => false)

    template = Feather::Template.new('{{?boolean}}true{{/}}{{?!boolean}}false{{/}}')

    assert_equal 'false', template.render
    assert_equal 'true', template.render(:boolean => true)
    assert_equal 'false', template.render(:boolean => false)

    template = Feather::Template.new('{{?boolean}}{{true}}{{/boolean}}{{?!boolean}}{{false}}{{/boolean}}')

    assert_equal '', template.render
    assert_equal 'TRUE', template.render(:boolean => true, :true => 'TRUE')
    assert_equal 'FALSE', template.render(:boolean => false, :false => 'FALSE')
    
    template = Feather::Template.new('{{?boolean}}{{/boolean}}{{?!boolean}}{{/boolean}}')
    
    assert_equal '', template.render
    assert_equal '', template.render(:boolean => true)
    assert_equal '', template.render(:boolean => false)
  end
  
  def test_sectioned_templates
    template = Feather::Template.new('<head>{{:head}}<{{tag}}>{{/}}</head>')
    
    assert_equal '<head><meta></head>', template.render(:head => 'meta')
    assert_equal '<head><meta></head>', template.render('head' => 'meta')
    assert_equal '<head><meta><link></head>', template.render(:head => %w[ meta link ])
    assert_equal '<head><meta><link></head>', template.render('head' => [ :meta, :link ])
    assert_equal '<head><meta><link></head>', template.render(:head => [ { :tag => 'meta' }, { :tag => 'link' } ])
    assert_equal '<head><meta><link></head>', template.render('head' => [ { 'tag' => :meta }, { 'tag' => :link } ])
    assert_equal '<head></head>', template.render
    assert_equal '<head></head>', template.render([ ])
    assert_equal '<head></head>', template.render({ })
    assert_equal '<head><></head>', template.render('')
    assert_equal '<head><></head>', template.render(:head => '')
    assert_equal '<head></head>', template.render(:head => nil)
    assert_equal '<head></head>', template.render(:head => [ ])

    template = Feather::Template.new('<div>{{:link}}<a href="{{href}}" alt="{{alt}}">{{/}}</div>')
    
    assert_equal '<div><a href="meta" alt=""></div>', template.render(:link => 'meta')
    assert_equal '<div><a href="meta" alt="link"></div>', template.render(:link => [ %w[ meta link ] ])
    assert_equal '<div><a href="/h" alt=""><a href="" alt="alt"><a href="/" alt="top"></div>', template.render(:link => [ { :href => '/h' }, { :alt => 'alt' }, { :href => '/', :alt => 'top' } ])
    assert_equal '<div></div>', template.render
    assert_equal '<div></div>', template.render(:link => nil)
    assert_equal '<div></div>', template.render(:link => [ ])
  end

  def test_empty_section
    template = Feather::Template.new('<head>{{:head}}{{tag}}{{/head}}{{^head}}<title></title>{{/head}}</head>')

    assert_equal '<head><title></title></head>', template.render
    assert_equal '<head><title></title></head>', template.render(:head => nil)
    assert_equal '<head><title></title></head>', template.render(:head => '')
    assert_equal '<head><title></title></head>', template.render(:head => [ ])
    assert_equal '<head><title></title></head>', template.render(:head => { })
    assert_equal '<head>0</head>', template.render(:head => 0)
    assert_equal '<head><test><tags></head>', template.render(:head => %w[ <test> <tags> ])
  end

  def test_comment
    template = Feather::Template.new('<test>{{!commment with all kinds of <markup>}}</test>')

    assert_equal '<test></test>', template.render
    assert_equal '<test></test>', template.render(:comment => 'test')
  end
  
  def test_template_with_context
    template = Feather::Template.new('{{example}}', :escape => :html)
    
    assert_equal '&lt;strong&gt;', template.render('<strong>')

    template = Feather::Template.new('{{=example}}', :escape => :html)
    
    assert_equal '<strong>', template.render('<strong>')
  end

  def test_recursive_templates
    template = Feather::Template.new('{{*example}}', :escape => :html)
    
    assert_equal 'child', template.render(nil, { :example => '{{*parent}}', :parent => 'child' }.freeze)
    assert_equal 'child', template.render(nil, { 'example' => '{{*parent}}', 'parent' => 'child' }.freeze)
  end

  def test_dynamic_variables
    template = Feather::Template.new('{{example}}{{text}}', :escape => :html)
    
    generator = Hash.new do |h, k|
      h[k] = "<#{k}>"
    end
    
    assert_equal '&lt;example&gt;&lt;text&gt;', template.render(generator)
  end
  
  def test_dynamic_templates
    template = Feather::Template.new('<{{*example}}>', :escape => :html)
    
    generator = Hash.new do |h, k|
      h[k] = k.to_s.upcase
    end
    
    assert_equal '<EXAMPLE>', template.render(nil, generator)
  end

  def test_missing_templates
    template = Feather::Template.new('{{*example}}', :escape => :html)
    
    assert_equal '', template.render(nil, { })
  end

  def test_recursive_circular_templates
    template = Feather::Template.new('{{*reference}}', :escape => :html)
    
    assert_exception Feather::Template::RecursionError do
      template.render(nil, { :reference => '{{*backreference}}', :backreference => '{{*reference}}' }.freeze)
    end
  end
  
  def test_parent_templates
    parent_template = Feather::Template.new('{{a}}[{{*}}]{{b}}'.freeze)
    child_template = Feather::Template.new('{{c}}{{*}}'.freeze)
    final_template = Feather::Template.new('{{a}}'.freeze)
    
    variables = { :a => 'A', :b => 'B', :c => 'C' }
    
    assert_equal 'A', final_template.render(variables)
    assert_equal 'CA', final_template.render(variables, nil, child_template)
    assert_equal 'A[CA]B', final_template.render(variables, nil, [ child_template, parent_template ].freeze)
  end

  def test_inline_parent_templates
    template = Feather::Template.new('{{a}}')
    
    variables = { :a => 'A', :b => 'B', :c => 'C' }
    
    assert_equal 'A', template.render(variables)
    assert_equal 'CA', template.render(variables, nil, '{{c}}{{*}}'.freeze)
    assert_equal 'A[CA]B', template.render(variables, nil, %w[ {{c}}{{*}} {{a}}[{{*}}]{{b}} ].freeze)
  end
  
  def test_extract_variables
    template = Feather::Template.new('{{a}}{{?b}}{{=c}}{{/b}}{{&d}}{{$e}}{{.f}}{{%g}}{{:h}}{{i}}{{/h}}')
    
    variables = { }
    sections = { }
    templates = { }

    template.compile(
      :variables => variables,
      :sections => sections,
      :templates => templates
    )
    
    assert_equal [ :a, :b, :c, :d, :e, :f, :g, :i ], variables.keys.sort_by(&:to_s)
    assert_equal [ :h ], sections.keys.sort_by(&:to_s)
    assert_equal [ ], templates.keys.sort_by(&:to_s)
  end

  def test_chain_extract_variables
    template = Feather::Template.new('{{a}}{{?b}}{{=c}}{{/b}}{{&d}}{{$e}}{{.f}}{{%g}}{{:h}}{{i}}{{/h}}')
    
    variables = { :x => true }
    sections = { :y => true }
    templates = { :z => true }

    template.compile(
      :variables => variables,
      :sections => sections,
      :templates => templates
    )
    
    assert_equal [ :a, :b, :c, :d, :e, :f, :g, :i, :x ], variables.keys.sort_by(&:to_s)
    assert_equal [ :h, :y ], sections.keys.sort_by(&:to_s)
    assert_equal [ :z ], templates.keys.sort_by(&:to_s)
  end

  def test_variable_tracker
    tracker = Feather::Template::VariableTracker.new
    
    assert_equal true, tracker.empty?
    assert_equal 0, tracker[:a]
    assert_equal 1, tracker[:b]
    assert_equal 2, tracker[:c]
    assert_equal 0, tracker[:a]
    assert_equal 2, tracker[:c]
    assert_equal 3, tracker[:z]
  end
  
  def test_clone
    template = Feather::Template.new('<p>{{example}}</p>', :escape => :html)
  
    cloned = template.clone
    
    assert_equal '<p>&lt;strong&gt;</p>', cloned.render('<strong>')
  end
  
  def test_serialization_with_yaml
    template = Feather::Template.new('<p>{{example}}</p>', :escape => :html)
    
    assert_equal '<p>&lt;strong&gt;</p>', template.render('<strong>')
    
    serialized_template = YAML.dump(template)
    
    deserialized_template = YAML.load(serialized_template)
    
    assert_equal '<p>&lt;strong&gt;</p>', deserialized_template.render('<strong>')
  end

  def test_serialization_with_marshal
    template = Feather::Template.new('<p>{{example}}</p>', :escape => :html)
    
    assert_equal '<p>&lt;strong&gt;</p>', template.render('<strong>')
    
    serialized_template = Marshal.dump(template)
    
    deserialized_template = Marshal.load(serialized_template)
    
    assert_equal '<p>&lt;strong&gt;</p>', deserialized_template.render('<strong>')
  end
  
  def test_with_broken_input
    template = Feather::Template.new('{{}}')
    
    assert_equal '', template.render
    assert_equal '', template.render(nil)
    assert_equal '', template.render(nil => nil)
    
    template = Feather::Template.new('{{test}}')
    
    assert_equal '', template.render(nil => nil)
  end
end
