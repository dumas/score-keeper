module Spec
  module Example
    module ExampleMethods
      extend ExampleGroupMethods
      extend ModuleReopeningFix

      include ::Spec::Matchers
      include ::Spec::Example::Pending
      
      attr_reader :_example

      def execute(options)
        options.reporter.example_started(_example)
        if options.dry_run
          if use_generated_description?
            _example.description = "NO NAME (Because of --dry-run)"
          end
          return options.reporter.example_finished(_example, nil, _example.description)
        end

        e = nil
        Timeout.timeout(options.timeout) do
          begin
            run_before_each
            run
          rescue Exception => ex
            e ||= ex
          ensure
            begin
              Spec::Matchers.clear_generated_description
              run_after_each
              verify_mocks_for_rspec
            rescue Exception => ex
              e ||= ex
            ensure
              teardown_mocks_for_rspec
            end
          end
        end

        options.reporter.example_finished(
          _example,
          e,
          _example.description
        )
        success = e.nil? || ExamplePendingError === e
      end
      
      def violated(message="")
        raise Spec::Expectations::ExpectationNotMetError.new(message)
      end
      
      def run
        _example.run_in(self)
      end
      
      def use_generated_description?
        _example.description == :__generate_docstring
      end

      def copy_instance_variables_from(obj)
        super(obj, [:@_example, :@_result])
      end

      def run_before_each
        setup_mocks_for_rspec
        self.class.run_before_each(self)
      end

      def run_after_each
        self.class.run_after_each(self)
      end

      def eval_each_fail_fast(procs) #:nodoc:
        procs.each do |proc|
          instance_eval(&proc)
        end
      end

      def eval_each_fail_slow(procs) #:nodoc:
        first_exception = nil
        procs.each do |proc|
          begin
            instance_eval(&proc)
          rescue Exception => e
            first_exception ||= e
          end
        end
        raise first_exception if first_exception
      end

    end
  end
end