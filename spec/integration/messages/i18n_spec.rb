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

  def store_translations(**translations)
    I18n.backend.store_translations(
      :en,
      messages.config.top_namespace => translations
    )
  end

  def store_errors(**errors)
    store_translations(errors: errors)
  end

  describe '#[]' do
    context 'when config.default_locale is set' do
      let(:options) do
        { default_locale: :pl }
      end

      it 'returns a message' do
        template, meta = messages[:size?, path: :age, size: 10]

        expect(template.()).to eql('wielkość musi być równa 10')
        expect(meta).to eql({})
      end
    end

    context 'with the default locale set via I18n.locale=' do
      before do
        I18n.locale = :pl
      end

      it 'returns nil when message is not defined' do
        expect(messages[:not_here, path: :srsly]).to be(nil)
      end

      it 'returns a message for a predicate' do
        template, meta = messages[:filled?, path: :name]

        expect(template.()).to eql('nie może być pusty')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific rule' do
        template, meta = messages[:filled?, path: :email]

        expect(template.()).to eql('Proszę podać adres email')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific val type' do
        template, meta = messages[:size?, path: :pages, val_type: String]

        expect(template.(size: 2)).to eql('wielkość musi być równa 2')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific rule and its default arg type' do
        template, meta = messages[:size?, path: :pages]

        expect(template.(size: 2)).to eql('wielkość musi być równa 2')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific rule and its arg type' do
        template, meta = messages[:size?, path: :pages, arg_type: Range]

        expect(template.(size_left: 1, size_right: 2)).to eql('wielkość musi być między 1 a 2')
        expect(meta).to eql({})
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

        it 'can use a proc for a rule value' do
          store_translations(
            rules: {
              rule_proc: ->(*) { 'Called' }
            }
          )

          expect(messages.rule(:rule_proc, locale: :en)).to eql('Called')
        end
      end

      describe 'fallbacking to I18n.default_locale with fallback backend config' do
        before do
          require 'i18n/backend/fallbacks'

          # https://github.com/svenfuchs/i18n/pull/415
          # Since I18n does not provide default fallbacks anymore, we have to do this explicitly
          I18n::Backend::Simple.include I18n::Backend::Fallbacks
          I18n.fallbacks = I18n::Locale::Fallbacks.new(:en)
        end

        it 'returns a message for a predicate in the default_locale' do
          template, meta = messages[:even?, path: :some_number]

          expect(I18n.locale).to eql(:pl)
          expect(template.()).to eql('must be even')
          expect(meta).to eql({})
        end
      end
    end

    context 'with a different locale' do
      it 'returns a message for a predicate' do
        template, meta = messages[:filled?, path: :name, locale: :en]

        expect(template.()).to eql('must be filled')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific rule' do
        template, meta = messages[:filled?, path: :email, locale: :en]

        expect(template.()).to eql('Please provide your email')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific rule and its default arg type' do
        template, meta = messages[:size?, path: :pages, locale: :en]

        expect(template.(size: 2)).to eql('size must be 2')
        expect(meta).to eql({})
      end

      it 'returns a message for a specific rule and its arg type' do
        template, meta = messages[:size?, path: :pages, arg_type: Range, locale: :en]

        expect(template.(size_left: 1, size_right: 2)).to eql('size must be within 1 - 2')
        expect(meta).to eq({})
      end

      it 'can use a proc for a message' do
        store_errors(
          predicate_proc: ->(_path, opts) { opts[:text] }
        )

        template, meta = messages[:predicate_proc, path: :path, text: 'text']

        expect(template.()).to eql('text')
        expect(meta).to eql({})
      end

      context 'with meta-data' do
        it 'finds the meta-data' do
          store_errors(
            predicate_with_meta: {
              text: 'text',
              code: 123
            }
          )

          template, meta = messages[:predicate_with_meta, path: :path]

          expect(template.()).to eql('text')
          expect(meta).to eql(code: 123)
        end
      end
    end

    context 'with dynamic locale' do
      it 'uses current locale in cache key and returns different messages for different locales' do
        template, meta = I18n.with_locale(:en) { messages[:filled?, path: :name] }
        expect(template.()).to eql('must be filled')
        expect(meta).to eql({})

        template, meta = I18n.with_locale(:pl) { messages[:filled?, path: :name] }
        expect(template.()).to eql('nie może być pusty')
        expect(meta).to eql({})
      end
    end
  end
end
