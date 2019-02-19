require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema::Messages::I18n do
  subject(:messages) { Dry::Schema::Messages::I18n.new }

  before do
    I18n.config.available_locales_set << :pl
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
    I18n.locale = :pl
    I18n.reload!
  end

  describe '#[]' do
    context 'with the default locale' do
      it 'returns nil when message is not defined' do
        expect(messages[:not_here, path: :srsly]).to be(nil)
      end

      it 'returns a message for a predicate' do
        template = messages[:filled?, path: :name]

        expect(template.()).to eql("nie może być pusty")
      end

      it 'returns a message for a specific rule' do
        template = messages[:filled?, path: :email]

        expect(template.()).to eql("Proszę podać adres email")
      end

      it 'returns a message for a specific val type' do
        template = messages[:size?, path: :pages, val_type: String]

        expect(template.(size: 2)).to eql("wielkość musi być równa 2")
      end

      it 'returns a message for a specific rule and its default arg type' do
        template = messages[:size?, path: :pages]

        expect(template.(size: 2)).to eql("wielkość musi być równa 2")
      end

      it 'returns a message for a specific rule and its arg type' do
        template = messages[:size?, path: :pages, arg_type: Range]

        expect(template.(size_left: 1, size_right: 2)).to eql("wielkość musi być między 1 a 2")
      end
    end

    context 'with a different locale' do
      it 'returns a message for a predicate' do
        template = messages[:filled?, path: :name, locale: :en]

        expect(template.()).to eql("must be filled")
      end

      it 'returns a message for a specific rule' do
        template = messages[:filled?, path: :email, locale: :en]

        expect(template.()).to eql("Please provide your email")
      end

      it 'returns a message for a specific rule and its default arg type' do
        template = messages[:size?, path: :pages, locale: :en]

        expect(template.(size: 2)).to eql("size must be 2")
      end

      it 'returns a message for a specific rule and its arg type' do
        template = messages[:size?, path: :pages, arg_type: Range, locale: :en]

        expect(template.(size_left: 1, size_right: 2)).to eql("size must be within 1 - 2")
      end
    end

    context 'fallbacking to I18n.default_locale with fallback backend config' do
      before do
        require "i18n/backend/fallbacks"

        # https://github.com/svenfuchs/i18n/pull/415
        # Since I18n does not provide default fallbacks anymore, we have to do this explicitly
        I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
        I18n.fallbacks = I18n::Locale::Fallbacks.new(:en)
      end

      it 'returns a message for a predicate in the default_locale' do
        template = messages[:even?, path: :some_number]

        expect(I18n.locale).to eql(:pl)
        expect(template.()).to eql("must be even")
      end
    end
  end

  describe '#rule' do
    it 'returns rule name using default locale' do
      expect(messages.rule(:email)).to eql('Adres mailowy')
    end

    it 'returns rule name using provided locale' do
      expect(messages.rule(:email, locale: :en)).to eql('E-mail address')
    end

    it 'returns rule name using default locale within a namespace' do
      expect(messages.namespaced(:company).rule(:email)).to eql('Email firmowy')
    end

    it 'returns rule name using provided locale within a namespace' do
      expect(messages.namespaced(:company).rule(:email, locale: :en)).to eql('Company email')
    end
  end
end
