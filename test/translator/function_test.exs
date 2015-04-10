defmodule ExToJS.Translator.Function.Test do
  use ExUnit.Case
  import ExToJS.TestHelper

  test "translate functions" do
    ex_ast = quote do
      def test1() do
      end
    end

    js_code = """
      export function test1(){
        return null;
      }
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      def test1(alpha, beta) do
      end
    end

    js_code = """
      export function test1(alpha, beta){
        return null;
      }
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      def test1(alpha, beta) do
        a = alpha
      end
    end

    js_code = """
      export function test1(alpha, beta){
        let a = alpha;
        return a;
      }
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      def test1(alpha, beta) do
        if 1 == 1 do
          1
        else
          2
        end
      end
    end

    js_code = """
      export function test1(alpha, beta){
        return (function(){
          if(1 == 1){
            return 1;
          }else{
            return 2;
          }
        }());;
      }
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      def test1(alpha, beta) do
        if 1 == 1 do
          if 2 == 2 do
            4
          else
            a = 1
          end
        else
          2
        end
      end
    end

    js_code = """
      export function test1(alpha, beta){
        return (function(){
          if(1 == 1){
            return (function(){
              if(2 == 2){
                return 4;
              }else{
                let a = 1;
                return a;
              }
            }());;
          }else{
            return 2;
          }
        }());;
      }
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      def test1(alpha, beta) do
        {a, b} = {1, 2}
      end
    end

    js_code = """
      export function test1(alpha, beta){
        let _ref = Tuple(1, 2);
        let a = _ref[0];
        let b = _ref[1];
        return _ref;
      }
    """

    assert_translation(ex_ast, js_code)
  end

  test "translate function calls" do
    ex_ast = quote do
      test1()
    end

    js_code = "test1()"

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      test1(3, 2)
    end

    js_code = "test1(3,2)"

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      Taco.test1()
    end

    js_code = "ElixirScript.get_property_or_call_function(Taco, 'test1')"   

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      Taco.test1(3, 2)
    end

    js_code = "Taco.test1(3,2)"   

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      Taco.test1(Taco.test2(1), 2)
    end

    js_code = "Taco.test1(Taco.test2(1),2)"   

    assert_translation(ex_ast, js_code)
  end


  test "translate anonymous functions" do
    ex_ast = quote do
      Enum.map(list, fn(x) -> x * 2 end)
    end

    js_code = "Enum.map(list, x => {(x * 2)})"

    assert_translation(ex_ast, js_code)
  end

  test "translate function arity" do
    ex_ast = quote do
      defmodule Example do
        defp example() do
        end

        defp example(oneArg) do
        end

        defp example(oneArg, twoArg) do
        end

        defp example(oneArg, twoArg, redArg) do
        end

        defp example(oneArg, twoArg, redArg, blueArg) do
        end
      end
    end 

    js_code = """
      const __MODULE__ = Atom('Example');

      function example__0(){ return null; }
      function example__1(oneArg){ return null; }
      function example__2(oneArg, twoArg){ return null; }
      function example__3(oneArg, twoArg, redArg){ return null; }
      function example__4(oneArg, twoArg, redArg, blueArg){ return null; }

      function example(...args){
        switch(args.length){
          case 0:
            return example__0.apply(null, args.slice(0, 0 - 1));
          case 1:
            return example__1.apply(null, args.slice(0, 1 - 1));
          case 2:
            return example__2.apply(null, args.slice(0, 2 - 1));
          case 3:
            return example__3.apply(null, args.slice(0, 3 - 1));
          default:
            return example__4.apply(null, args);
        }
      }
    """  
    assert_translation(ex_ast, js_code)


    ex_ast = quote do
      defmodule Example do
        def example() do
        end

        def example(oneArg) do
        end

        def example(oneArg, twoArg) do
        end

        def example(oneArg, twoArg, redArg) do
        end

        def example(oneArg, twoArg, redArg, blueArg) do
        end
      end
    end 

    js_code = """
      const __MODULE__ = Atom('Example');

      function example__0(){ return null; }
      function example__1(oneArg){ return null; }
      function example__2(oneArg, twoArg){ return null; }
      function example__3(oneArg, twoArg, redArg){ return null; }
      function example__4(oneArg, twoArg, redArg, blueArg){ return null; }

      export function example(...args){
        switch(args.length){
          case 0:
            return example__0.apply(null, args.slice(0, 0 - 1));
          case 1:
            return example__1.apply(null, args.slice(0, 1 - 1));
          case 2:
            return example__2.apply(null, args.slice(0, 2 - 1));
          case 3:
            return example__3.apply(null, args.slice(0, 3 - 1));
          default:
            return example__4.apply(null, args);
        }
      }
    """  
    assert_translation(ex_ast, js_code)


    ex_ast = quote do
      defmodule Example do
        def example(oneArg) do
        end
      end
    end 

    js_code = """
      const __MODULE__ = Atom('Example');

      export function example(oneArg){
        return null;
      }
    """  
    assert_translation(ex_ast, js_code)

  end

  test "test |> operator" do
    ex_ast = quote do
      1 |> Taco.test
    end

    js_code = "Taco.test(1)"

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      1 |> Taco.test |> Home.hello("hi")
    end

    js_code = "Home.hello(Taco.test(1), 'hi')"

    assert_translation(ex_ast, js_code)
  end


  test "test Kernel function" do
    ex_ast = quote do
      is_atom(:atom)
    end

    js_code = "Kernel.is_atom(Atom('atom'))"

    assert_translation(ex_ast, js_code)
  end

  @tag :skip
  test "guards" do
    ex_ast = quote do
      def something(one) when is_number(one) do
      end
    end


    js_code = """
      export function something(one){
        if(Kernel.is_number(one)){

        }else{
          throw new ArgumentError();
        }
      }
    """

  end

  @tag :skip
  test "pattern matching" do
    ex_ast = quote do
      def something(1) do
      end
    end


    js_code = """
      export function something(_ref){
        if(_ref === 1){

        }else{
          throw new ArgumentError();
        }
      }
    """

  end

  
end