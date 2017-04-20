# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class ProcAction
    def initialize(&block)
      @block = block
    end

    def execute
      @block.call
    end
  end
end
