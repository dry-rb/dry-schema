# frozen_string_literal: true

require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema::Messages::I18n do
  subject(:messages) { Dry::Schema::Messages::I18n.build(options) }

  let(:options) do
    {}
  end

  before do
    I18n.config.available_locales = [:en, :pl]
    I18n.load_path.concat(%w[en pl].map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
    I18n.reload!
  end

  describe '#lookup' do
    context 'when config.default_locale is set' do
      let(:options) do
        { default_locale: :pl }
      end

      it 'returns a message' do
        result = messages.lookup(:size?, { size: 3 }, path: :age, size: 10)

        expect(result).to eql(
          text: 'wielkość musi być równa 3',
          meta: {}
        )
      end
    end

    context 'with the default locale set via I18n.locale=' do
      before do
        I18n.locale = :pl
      end

      it 'returns nil when message is not defined' do
        expect(messages.lookup(:not_here, {}, path: :srsly)).to be(nil)
      end

      it 'returns a message for a predicate' do
        result = messages.lookup(:filled?, {}, path: :name)

        expect(result).to eql(
          text: 'nie może być pusty',
          meta: {}
        )
      end

      it 'returns a message for a specific rule' do
        result = messages.lookup(:filled?, {}, path: :email)

        expect(result).to eql(
          text: 'Proszę podać adres email',
          meta: {}
        )
      end

      it 'returns a message for a specific val type' do
        result = messages.lookup(:size?, { size: 2 }, path: :pages, val_type: String)

        expect(result).to eql(
          text: 'wielkość musi być równa 2',
          meta: {}
        )
      end

      it 'returns a message for a specific rule and its default arg type' do
        result = messages.lookup(:size?, { size: 2 }, path: :pages)

        expect(result).to eql(
          text: 'wielkość musi być równa 2',
          meta: {}
        )
      end

      it 'returns a message for a specific rule and its arg type' do
        result = messages.lookup(
          :size?,
          { size_left: 1, size_right: 2 },
          path: :pages,
          arg_type: Range
        )

        expect(result).to eql(
          text: 'wielkość musi być między 1 a 2',
          meta: {}
        )
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
          result = messages.lookup(:even?, {}, path: :some_number)

          expect(I18n.locale).to eql(:pl)
          expect(result).to eql(
            text: 'must be even',
            meta: {}
          )
        end
      end
    end

    context 'with a different locale' do
      it 'returns a message for a predicate' do
        result = messages.lookup(:filled?, {}, path: :name, locale: :en)

        expect(result).to eql(
          text: 'must be filled',
          meta: {}
        )
      end

      it 'returns a message for a specific rule' do
        result = messages.lookup(:filled?, {}, path: :email, locale: :en)

        expect(result).to eql(
          text: 'Please provide your email',
          meta: {}
        )
      end

      it 'returns a message for a specific rule and its default arg type' do
        result = messages.lookup(:size?, { size: 2 }, path: :pages, locale: :en)

        expect(result).to eql(
          text: 'size must be 2',
          meta: {}
        )
      end

      it 'returns a message for a specific rule and its arg type' do
        result = messages.lookup(
          :size?,
          { size_left: 1, size_right: 2 },
          path: :pages,
          arg_type: Range,
          locale: :en
        )

        expect(result).to eql(
          text: 'size must be within 1 - 2',
          meta: {}
        )
      end

      context 'with meta-data' do
        def store_translation(translation)
          I18n.backend.store_translations(
            :en,
            messages.config.top_namespace => {
              errors: {
                predicate_with_meta: translation
              }
            }
          )
        end

        it 'finds the meta-data' do
          store_translation(text: 'text', code: 123)

          result = messages.lookup(:predicate_with_meta, {}, path: :path)

          expect(result).to eq(
            text: 'text',
            meta: { code: 123 }
          )
        end

        it 'correctly handles the proc form' do
          store_translation(text: ->(*) { 'text' }, code: ->(*) { 123 })

          result = messages.lookup(:predicate_with_meta, {}, path: :path)

          expect(result).to eq(
            text: 'text',
            meta: { code: 123 }
          )
        end
      end
    end

    context 'with dynamic locale' do
      it 'uses current locale in cache key and returns different messages for different locales' do
        expect(I18n.with_locale(:en) { messages.lookup(:filled?, {}, path: :name) }).to eql(
          text: 'must be filled',
          meta: {}
        )

        expect(I18n.with_locale(:pl) { messages.lookup(:filled?, {}, path: :name) }).to eql(
          text: 'nie może być pusty',
          meta: {}
        )
      end
    end
  end
end
