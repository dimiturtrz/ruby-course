describe '#convert_to_bgn' do
  it 'converts usd' do
    expect(convert_to_bgn(1000, :usd)).to eq 1740.8
  end
end

describe '#compare_prices' do
  it 'compares prices of the same currency' do
    expect(compare_prices(10, :usd, 13, :usd)).to be < 0
    expect(compare_prices(10, :eur, 10, :eur)).to eq 0
    expect(compare_prices(10, :gbp, 8, :gbp)).to be > 0
  end
end

describe '#compare_prices' do
  it 'compares prices of the different currency' do
    expect(compare_prices(10, :usd, 10, :eur)).to be < 0
    expect(compare_prices(4, :gbp, 10, :bgn)).to be > 0
    expect(compare_prices(26415, :usd, 17408, :gbp)).to eq 0
  end
end
