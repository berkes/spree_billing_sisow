describe 'Deprecated BillingIntegration' do
  before { Gem::Deprecate.skip, @original = true, Gem::Deprecate.skip }
  after { Gem::Deprecate.skip = @original }

  it 'returns the an instance scoped to PaymentMethod instead' do
    payment_methods.each do |payment_method|
      subject = build_class('BillingIntegration', payment_method).new
      expect(subject).to be_a_kind_of(build_class('PaymentMethod', payment_method))
    end
  end

  it 'passes the attributes on to the new instantiation' do
    payment_methods.each do |payment_method|
      subject = build_class('BillingIntegration', payment_method).new(name: 'foo')
      expect(subject.name).to eq 'foo'
    end
  end

  def payment_methods
    %w(Ideal Bancontact Sofort)
  end

  def build_class(swappable_class, payment_method)
    "Spree::#{swappable_class}::SisowBilling::#{payment_method}".constantize
  end
end
