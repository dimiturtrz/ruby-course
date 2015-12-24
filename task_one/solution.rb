BGN_EXCHANGE_RATES = {usd: 1.7408, eur: 1.9557, gbp: 2.6415, bgn: 1.0}

def convert_to_bgn(price, currency)
  (price * BGN_EXCHANGE_RATES[currency]).round(2)
end

def compare_prices(first_price, first_currency, second_price, second_currency)
  convert_to_bgn(first_price, first_currency) <=>
    convert_to_bgn(second_price, second_currency)
end
