# frozen_string_literal: true

require 'dry/schema/messages/template'

RSpec.describe Dry::Schema::Messages::Template do
  describe '.[]' do
    it 'builds a template from a text with tokens' do
      text = '%{value} looks %{how} and %{this31} and %{tha_t_21} too'
      template = Dry::Schema::Messages::Template[text]

      data = { value: 'this', how: 'good', this31: 'this', tha_t_21: 'that' }

      expect(template.(data).to_s).to eql('this looks good and this and that too')
    end

    it 'builds a template from a text without tokens' do
      template = Dry::Schema::Messages::Template['this is good']

      expect(template.().to_s).to eql('this is good')
    end
  end
end
