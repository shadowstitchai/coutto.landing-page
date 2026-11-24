# ponytail: liquid 4.0.3 (pinned by github-pages) calls String#tainted?, removed in Ruby 3.2.
# Delete this file when github-pages ships a newer liquid.
unless Object.method_defined?(:tainted?)
  class Object
    def tainted?
      false
    end

    def taint
      self
    end

    def untaint
      self
    end
  end
end
