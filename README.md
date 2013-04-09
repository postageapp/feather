# feather

A simple text template system inspired by Mustache for generating output for a
variety of uses including plain-text, HTML, and JavaScript.

## Examples

The straight-forward usage is substitutions:

    template = Feather::Template.new("This {{noun}} is {{adjective}}")
    
    template.render(:noun => 'shoe', :adjective => 'red')
    # => "This shoe is red"

If required, the content can be HTML-escaped automatically:

    template = Feather::Template.new(
      "This {{noun}} is {{adjective}}",
      :escape => :html
    )

    template.render(:noun => 'goose', :adjective => '<em>blue</em>')
    # => "This goose is &lt;em&gt;blue&lt;/em&gt;"
    
This can also be engaged on a case-by-case basis:

    template = Feather::Template.new("This {{&noun}} is {{adjective}}")

    template.render(:noun => '<b>goose</b>', :adjective => '<em>blue</em>')
    # => "This &lt;b&gt;goose&lt;/b&gt; is <em>blue</em>"

Also available is URI encoding for links:

    template = Feather::Template.new(
      "<a href='/home?user_id={{%user_id}}'>{{&label}}</a>"
    )
    
    template.render(:user_id => 'joe&2', :label => 'Joe&2')
    # => "<a href='/home?user_id=joe%262'>Joe&amp;2</a>"

A sample template is located in:

    notes/example.ft

A number of other usage cases are described in test/test_feather_template.rb
as a reference.

## Copyright

Copyright (c) 2011-2013 Scott Tadman, The Working Group Inc.
See LICENSE.txt for further details.

