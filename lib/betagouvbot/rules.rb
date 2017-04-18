# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/mail'

module BetaGouvBot
  RULES = {
    21 => { mail: Mail.from_file('data/body_21.md',
                                 ['{{author.id}}@beta.gouv.fr']) },
    14 => { mail: Mail.from_file('data/body_14.md',
                                 ['{{author.id}}@beta.gouv.fr',
                                  'contact@beta.gouv.fr']) },
    1 =>  { mail: Mail.from_file('data/body_1.md',
                                 ['{{author.id}}@beta.gouv.fr']) },
    -1 => { mail: Mail.from_file('data/body_-1.md',
                                 ['contact@beta.gouv.fr']) }
  }.freeze
end
