# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Normalizy::Filters::Date do
  it { expect(subject.call('')).to eq '' }

  it { expect(subject.call('1984-10-23')).to eq Time.new(1984, 10, 23, 0, 0, 0, 0) }

  it { expect(subject.call('84/10/23', format: '%y/%m/%d')).to eq Time.new(1984, 10, 23, 0, 0, 0, 0) }

  it { expect(subject.call(Time.new(1984, 10, 23), adjust: :end)).to      eq Time.new(1984, 10, 23).end_of_day }
  it { expect(subject.call(Time.new(1984, 10, 23, 1), adjust: :begin)).to eq Time.new(1984, 10, 23).beginning_of_day }

  it 'accepts time zone' do
    time = subject.call('1984-10-23', time_zone: 'Tokelau Is.').utc

    expect(time).to eq Time.new(1984, 10, 23, time.hour, 0, 0, 0)
  end

  context 'with invalid date' do
    let!(:object)  { ModelDate.new }
    let!(:options) { { attribute: :date, object: object } }

    context 'with i18n present' do
      before do
        allow(I18n).to receive(:t).with(:date,
          scope:   ['normalizy.errors.date', 'model_date'],
          value:   '1984-10-00',
          default: '%{value} is an invalid date.').and_return 'date.error'
      end

      it 'writes an error on object and does not set the values' do
        subject.call '1984-10-00', options

        expect(object.errors[:date]).to eq ['date.error']
        expect(object.date).to          eq nil
      end
    end

    context 'with no I18n present' do
      it 'writes a default error on object and does not set the values' do
        subject.call '1984-10-00', options

        expect(object.errors[:date]).to eq ['1984-10-00 is an invalid date.']
        expect(object.date).to          eq nil
      end
    end
  end
end
