# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/mail'

module BetaGouvBot
  RULES = {
    21 => { mail: Mail.from_file('data/mail_3w.md',
                                 ['{{author.id}}@beta.gouv.fr']) },
    14 => { mail: Mail.from_file('data/mail_2w.md',
                                 ['{{author.id}}@beta.gouv.fr',
                                  'contact@beta.gouv.fr']) },
    1 =>  { mail: Mail.from_file('data/mail_1day.md',
                                 ['{{author.id}}@beta.gouv.fr']) },
    -1 => { mail: Mail.from_file('data/mail_after.md',
                                 ['contact@beta.gouv.fr']) }
  }.freeze
end
