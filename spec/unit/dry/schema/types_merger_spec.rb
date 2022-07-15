# frozen_string_literal: true

require "dry/types"
require "dry/logic"

require "dry/schema/types_merger"
require "dry/schema/type_registry"

RSpec.describe Dry::Schema::TypesMerger do
  let(:t) { Dry.Types }

  subject(:types_merger) { Dry::Schema::TypesMerger.new }

  describe "#call" do
    context Dry::Logic::Operations::Or do
      it "joins types with |" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::Or,
              {foo: t::Integer, bar: t::Integer},
              {foo: t::String}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :sum,
              [
                [
                  :constrained,
                  [
                    [:nominal, [Integer, {}]],
                    [
                      :predicate,
                      [:type?, [[:type, Integer], [:input, Undefined]]]
                    ]
                  ]
                ],
                [
                  :constrained,
                  [
                    [:nominal, [String, {}]],
                    [
                      :predicate,
                      [:type?, [[:type, String], [:input, Undefined]]]
                    ]
                  ]
                ],
                {}
              ]
            ],
            bar: [
              :constrained,
              [
                [:nominal, [Integer, {}]],
                [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
              ]
            ]
          }
        )
      end
    end

    context Dry::Logic::Operations::And do
      it "applies all when keys collide" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::And,
              {foo: t::Integer.constrained(gteq: 1)},
              {foo: t::Integer.constrained(lteq: 3)}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :constrained,
              [
                [:nominal, [Integer, {}]],
                [
                  :and,
                  [
                    [
                      :and,
                      [
                        [
                          :predicate,
                          [:type?, [[:type, Integer], [:input, Undefined]]]
                        ],
                        [:predicate, [:gteq?, [[:num, 1], [:input, Undefined]]]]
                      ]
                    ],
                    [
                      :and,
                      [
                        [
                          :predicate,
                          [:type?, [[:type, Integer], [:input, Undefined]]]
                        ],
                        [:predicate, [:lteq?, [[:num, 3], [:input, Undefined]]]]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          }
        )
      end

      it "merges schema types on collision" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::And,
              {foo: t::Hash.schema(bar: t::Integer)},
              {foo: t::Hash.schema(baz: t::Integer)}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :constrained,
              [
                [
                  :constrained,
                  [
                    [
                      :schema,
                      [
                        [
                          [
                            :key,
                            [
                              :bar,
                              true,
                              [
                                :key,
                                [
                                  :bar,
                                  true,
                                  [
                                    :constrained,
                                    [
                                      [:nominal, [Integer, {}]],
                                      [
                                        :predicate,
                                        [
                                          :type?,
                                          [
                                            [:type, Integer],
                                            [:input, Undefined]
                                          ]
                                        ]
                                      ]
                                    ]
                                  ]
                                ]
                              ]
                            ]
                          ],
                          [
                            :key,
                            [
                              :baz,
                              true,
                              [
                                :key,
                                [
                                  :baz,
                                  true,
                                  [
                                    :constrained,
                                    [
                                      [:nominal, [Integer, {}]],
                                      [
                                        :predicate,
                                        [
                                          :type?,
                                          [
                                            [:type, Integer],
                                            [:input, Undefined]
                                          ]
                                        ]
                                      ]
                                    ]
                                  ]
                                ]
                              ]
                            ]
                          ]
                        ],
                        {},
                        {}
                      ]
                    ],
                    [:predicate, [:type?, [[:type, Hash], [:input, Undefined]]]]
                  ]
                ],
                [
                  :and,
                  [
                    [
                      :predicate,
                      [:type?, [[:type, Hash], [:input, Undefined]]]
                    ],
                    [:predicate, [:type?, [[:type, Hash], [:input, Undefined]]]]
                  ]
                ]
              ]
            ]
          }
        )
      end

      it "uses the rhs if the lhs is an Any" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::And,
              {foo: t::Any},
              {foo: t::Integer}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :constrained,
              [
                [:nominal, [Integer, {}]],
                [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
              ]
            ]
          }
        )
      end

      it "uses the rhs if the rhs is a subclass of lhs" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::And,
              {foo: t::Hash},
              {foo: t::Hash.schema(bar: t::Integer)}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :constrained,
              [
                [
                  :schema,
                  [
                    [
                      [
                        :key,
                        [
                          :bar,
                          true,
                          [
                            :constrained,
                            [
                              [:nominal, [Integer, {}]],
                              [
                                :predicate,
                                [
                                  :type?,
                                  [[:type, Integer], [:input, Undefined]]
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ],
                    {},
                    {}
                  ]
                ],
                [
                  :and,
                  [
                    [
                      :predicate,
                      [:type?, [[:type, Hash], [:input, Undefined]]]
                    ],
                    [:predicate, [:type?, [[:type, Hash], [:input, Undefined]]]]
                  ]
                ]
              ]
            ]
          }
        )
      end

      it "uses the lhs if the rhs is an Any" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::And,
              {foo: t::Integer},
              {foo: t::Any}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :constrained,
              [
                [:nominal, [Integer, {}]],
                [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
              ]
            ]
          }
        )
      end

      it "uses the lhs if the lhs is a subclass of rhs" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::And,
              {foo: t::Hash.schema(bar: t::Integer)},
              {foo: t::Hash}
            )
            .transform_values(&:to_ast)
        ).to eq(
          {
            foo: [
              :constrained,
              [
                [
                  :schema,
                  [
                    [
                      [
                        :key,
                        [
                          :bar,
                          true,
                          [
                            :constrained,
                            [
                              [:nominal, [Integer, {}]],
                              [
                                :predicate,
                                [
                                  :type?,
                                  [[:type, Integer], [:input, Undefined]]
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ],
                    {},
                    {}
                  ]
                ],
                [
                  :and,
                  [
                    [
                      :predicate,
                      [:type?, [[:type, Hash], [:input, Undefined]]]
                    ],
                    [:predicate, [:type?, [[:type, Hash], [:input, Undefined]]]]
                  ]
                ]
              ]
            ]
          }
        )
      end
    end
  end
end
