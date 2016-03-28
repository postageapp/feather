require_relative './helper'

require 'yaml'

class TestFeatherSupport < MiniTest::Test
  def test_variable_stack_with_symbol_keys
    test = {
      test: [
        {
          a: 'a',
          b: 'b'
        },
        {
          c: 'c'
        }
      ]
    }
    
    variables = Feather::Support.variable_stack(test)
    
    assert_equal test, variables
    
    assert_equal 'a', variables[:test][0][:a]
    assert_equal 'b', variables[:test][0][:b]
    assert_equal 'c', variables[:test][1][:c]
    assert_equal nil, variables[:test][1][:d]
  end

  def test_variable_stack_with_string_keys
    test = {
      'test' => [
        {
          'a' => :a,
          'b' => :b
        },
        {
          'c' => :c
        }
      ]
    }
    
    variables = Feather::Support.variable_stack(test)
    
    assert_equal :a, variables[:test][0][:a]
    assert_equal :b, variables[:test][0][:b]
    assert_equal :c, variables[:test][1][:c]

    assert_equal 'test',  Feather::Support.variable_stack('test', false)
    assert_equal [ 'test' ],  Feather::Support.variable_stack('test')
    assert_equal [ 'test' ],  Feather::Support.variable_stack([ 'test' ], false)
    assert_equal [ 'test' ],  Feather::Support.variable_stack([ 'test' ])
  end

  def test_variable_stack_with_multiple_values
    variables = Feather::Support.variable_stack(
      head: [
        {
          tag: 'meta'
        },
        {
          tag: 'link'
        }
      ]
    )
    
    assert_equal 'meta', variables[:head][0][:tag]
    assert_equal 'link', variables[:head][1][:tag]
  end

  def test_variable_stack_with_deeper_nesting
    test = {
      'top' => {
        'layer' => 'top',
        't' => 'top',
        'middle' => {
          'layer' => 'middle',
          'm' => 'middle',
          'bottom' => {
            'layer' => 'bottom',
            'b' => 'bottom'
          }
        }
      }
    }
    
    variables = Feather::Support.variable_stack(test)
    
    assert_equal 'top', variables[:top][:t]
    assert_equal 'middle', variables[:top][:middle][:m]
    assert_equal 'bottom', variables[:top][:middle][:bottom][:b]

    assert_equal 'top', variables[:top][:layer]
    assert_equal 'middle', variables[:top][:middle][:layer]
    assert_equal 'bottom', variables[:top][:middle][:bottom][:layer]
  end
end
