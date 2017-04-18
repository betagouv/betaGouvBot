# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/mail'

module BetaGouvBot
  RULES = {
    21 => { mail: Mail.new('🗓 Fin de contrat prévue pour dans 3 semaines',
                           'body_21.md', ['{{author.id}}@beta.gouv.fr']) },
    14 => { mail: Mail.new('🗓 Fin de contrat prévue pour dans 1 semaines',
                           'body_21.md',
                           ['{{author.id}}@beta.gouv.fr', 'contact@beta.gouv.fr']) },
    1 => { mail: Mail.new('🗓 Fin de contrat prévue pour demain',
                          'body_1.md', ['{{author.id}}@beta.gouv.fr']) },
    -1 => { mail: Mail.new('Contrat expiré', 'body_-1.md',
                           ['contact@beta.gouv.fr']) }
  }.freeze
end
