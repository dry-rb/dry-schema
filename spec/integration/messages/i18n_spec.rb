# frozen_string_literal: true

require 'dry/schema/messages/template'
require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema::Messages::I18n do
  subject(:messages) { Dry::Schema::Messages::I18n.build(options) }

  let(:options) do
    {}
  end

  before do
    I18n.config.available_locales = [:en, :pl]
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
    I18n.reload!
  end

  describe '#[]' do
    context 'when config.default_locale is set' do
      let(:options) do
        { default_locale: :pl }
      end

      it 'returns a message template' do
        template, = messages[:size?, path: :age, size: 10]

        expect(template).to eql(Dry::Schema::Messages::Template['wielkość musi być równa %{size}'])
      end
    end

    context 'with the default locale set via I18n.locale=' do
      before do
        I18n.locale = :pl
      end

      it 'returns nil when message is not defined' do
        expect(messages[:not_here, path: :srsly]).to be(nil)
      end

      it 'returns a message template' do
        template, = messages[:size?, path: :age, size: 10]

        expect(template).to eql(Dry::Schema::Messages::Template['wielkość musi być równa %{size}'])
      end

      it 'caches message templates' do
        template, = messages[:size?, path: :age, size: 10]

        expect(messages[:size?, path: :age, size: 10][0]).to be(template)
      end

      it 'returns a message for a predicate' do
        template, = messages[:filled?, path: :name]

        expect(template.()).to eql('nie może być pusty')
      end

      it 'returns a message for a specific rule' do
        template, = messages[:filled?, path: :email]

        expect(template.()).to eql('Proszę podać adres email')
      end

      it 'returns a message for a specific val type' do
        template, = messages[:size?, path: :pages, val_type: String]

        expect(template.(size: 2)).to eql('wielkość musi być równa 2')
      end

      it 'returns a message for a specific rule and its default arg type' do
        template, = messages[:size?, path: :pages]

        expect(template.(size: 2)).to eql('wielkość musi być równa 2')
      end

      it 'returns a message for a specific rule and its arg type' do
        template, = messages[:size?, path: :pages, arg_type: Range]

        expect(template.(size_left: 1, size_right: 2)).to eql('wielkość musi być między 1 a 2')
      end

      describe '#translate' do
        it 'translates raw paths to stored translation texts' do
          expect(messages.translate(:or)).to eql('lub')
          expect(messages.translate(:or, locale: :en)).to eql('or')
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

      describe 'fallbacking to I18n.default_locale with fallback backend config' do
        before do
          require 'i18n/backend/fallbacks'

          # https://github.com/svenfuchs/i18n/pull/415
          # Since I18n does not provide default fallbacks anymore, we have to do this explicitly
          I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
          I18n.fallbacks = I18n::Locale::Fallbacks.new(:en)
        end

        it 'returns a message for a predicate in the default_locale' do
          template, = messages[:even?, path: :some_number]

          expect(I18n.locale).to eql(:pl)
          expect(template.()).to eql('must be even')
        end
      end
    end

    context 'with a different locale' do
      it 'returns a message for a predicate' do
        template, = messages[:filled?, path: :name, locale: :en]

        expect(template.()).to eql('must be filled')
      end

      it 'returns a message for a specific rule' do
        template, = messages[:filled?, path: :email, locale: :en]

        expect(template.()).to eql('Please provide your email')
      end

      it 'returns a message for a specific rule and its default arg type' do
        template, = messages[:size?, path: :pages, locale: :en]

        expect(template.(size: 2)).to eql('size must be 2')
      end

      it 'returns a message for a specific rule and its arg type' do
        template, = messages[:size?, path: :pages, arg_type: Range, locale: :en]

        expect(template.(size_left: 1, size_right: 2)).to eql('size must be within 1 - 2')
      end
    end

    context 'with dynamic locale' do
      it 'uses current locale in cache key and returns different messages for different locales' do
        template, = I18n.with_locale(:en) { messages[:filled?, path: :name] }
        expect(template.()).to eql('must be filled')

        template, = I18n.with_locale(:pl) { messages[:filled?, path: :name] }
        expect(template.()).to eql('nie może być pusty')
      end
    end
  end

  describe '#cache_key' do
    it "uses adds current locale when it's not passed or nil" do
      expect(I18n.with_locale(:en) { messages.cache_key(:size?, {}) })
        .to eql([:size?, {}, :en])
      expect(I18n.with_locale(:pl) { messages.cache_key(:size?, {}) })
        .to eql([:size?, {}, :pl])
      expect(I18n.with_locale(:en) { messages.cache_key(:size?, locale: nil) })
        .to eql([:size?, { locale: nil }, :en])
    end

    it "doesn't add current locale if it's passed explicitly" do
      expect(I18n.with_locale(:en) { messages.cache_key(:size?, locale: :pl) })
        .to eql([:size?, { locale: :pl }])
    end
  end
end
