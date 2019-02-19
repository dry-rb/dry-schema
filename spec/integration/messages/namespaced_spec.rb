require 'dry/schema/params'

RSpec.describe 'Namespaced messages' do
  context 'in nested schemas' do
    let!(:comment_schema) do
      Test::CommentSchema = Dry::Schema.Params do
        config.messages_file = "#{SPEC_ROOT}/fixtures/locales/namespaced.yml"
        config.namespace = :comment

        required(:comment_body).filled
      end
    end

    let(:post_schema) do
      Test::PostSchema = Dry::Schema.Params do
        config.messages_file = "#{SPEC_ROOT}/fixtures/locales/namespaced.yml"
        config.namespace = :post

        required(:post_body).filled
        required(:comment).schema(::Test::CommentSchema)
      end
    end

    it 'uses namespaced messages' do
      result = post_schema.call(post_body: '', comment: { comment_body: '' })

      expect(result.errors[:post_body]).to eql(["POST can't be blank"])
      expect(result.errors[:comment][:comment_body]).to eql(["COMMENT can't be blank"])
    end
  end
end
