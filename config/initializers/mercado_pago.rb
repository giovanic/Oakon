# O SDK oficial (mercadopago-sdk) não inclui o validador de assinatura de webhook
# no seu require principal (lib/mercadopago.rb) — precisa ser exigido à parte.
require "mercadopago/webhook/validator"
