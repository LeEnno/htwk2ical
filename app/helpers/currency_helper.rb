# encoding: utf-8
module CurrencyHelper
  def format_euro(amount, with_precision = false)
    number_to_currency amount,
                      :unit      => '€',
                      :separator => ',',
                      :format    => '%n%u',
                      :precision => with_precision ? 2 : 0
  end

  def format_dollar(amount, with_precision = false)
    number_to_currency amount, :precision => with_precision ? 2 : 0
  end
end