# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Normalizy::Filters::Date do
  it { expect(subject.call('')).to eq '' }

  it { expect(subject.call('1984-10-23')).to eq Time.new(1984, 10, 23, 0, 0, 0, 0) }

  it { expect(subject.call('84/10/23', format: '%y/%m/%d')).to eq Time.new(1984, 10, 23, 0, 0, 0, 0) }

  it 'accepts time zone' do
    time = subject.call('1984-10-23', time_zone: 'Tokelau Is.').utc

    expect(time).to eq Time.new(1984, 10, 23, time.hour, 0, 0, 0)
  end

  context 'with invalid date' do
    let!(:object)  { User.new }
    let!(:options) { { attribute: :birthday, object: object } }

    context 'with i18n present' do
      before do
        allow(I18n).to receive(:t).with(:birthday,
          scope:   ['normalizy.errors.date', 'user'],
          value:   '1984-10-00',
          default: '%{value} is an invalid date.') { 'birthday.error' }
      end

      it 'writes an error on object and does not set the values' do
        expected = Time.new(1984, 10, 23, 0, 0, 0, 0)

        subject.call '1984-10-00', options

        expect(object.errors[:birthday]).to eq ['birthday.error']
        expect(object.birthday).to          eq nil
      end
    end

    context 'with no I18n present' do
      it 'writes a default error on object and does not set the values' do
        expected = Time.new(1984, 10, 23, 0, 0, 0, 0)

        subject.call '1984-10-00', options

        expect(object.errors[:birthday]).to eq ['1984-10-00 is an invalid date.']
        expect(object.birthday).to          eq nil
      end
    end
  end
end