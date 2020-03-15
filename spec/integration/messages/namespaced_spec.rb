# frozen_string_literal: true

require "dry/schema/params"

RSpec.describe "Namespaced messages" do
  context "namespace with nested schema" do
    let(:post_schema) do
      Dry::Schema.Params do
        config.messages.load_paths << "#{SPEC_ROOT}/fixtures/locales/namespaced.yml"
        config.messages.namespace = :post

        required(:post_body).filled(:string)
        required(:comment).schema do
          required(:comment_body).filled(:string)
        end
      end
    end

    it "uses namespaced messages" do
      result = post_schema.call(post_body: "", comment: {comment_body: ""})

      expect(result.errors[:post_body]).to eql(["POST can't be blank"])

      expect(result.errors[:comment][:comment_body])
        .to eql(["post comment must be filled"])
    end
  end

  context "in nested, re-used schemas" do
    let!(:comment_schema) do
      Test::CommentSchema = Dry::Schema.Params do
        config.messages.load_paths << "#{SPEC_ROOT}/fixtures/locales/namespaced.yml"
        config.messages.namespace = :comment

        required(:comment_body).filled(:string)
      end
    end

    let(:post_schema) do
      Test::PostSchema = Dry::Schema.Params do
        config.messages.load_paths << "#{SPEC_ROOT}/fixtures/locales/namespaced.yml"
        config.messages.namespace = :post

        required(:post_body).filled(:string)
        required(:comment).hash(::Test::CommentSchema)
      end
    end

    it "uses namespaced messages" do
      result = post_schema.call(post_body: "", comment: {comment_body: ""})

      expect(result.errors[:post_body]).to eql(["POST can't be blank"])

      expect(result.errors[:comment][:comment_body])
        .to eql(["COMMENT can't be blank"])
    end
  end
end
