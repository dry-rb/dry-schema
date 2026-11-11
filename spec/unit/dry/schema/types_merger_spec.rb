# frozen_string_literal: true

require "dry/types"
require "dry/logic"

require "dry/schema/types_merger"
require "dry/schema/type_registry"

RSpec.describe Dry::Schema::TypesMerger do
  subject(:types_merger) { Dry::Schema::TypesMerger.new }

  describe "#call" do
    context Dry::Logic::Operations::Or do
      it "applies all when keys collide" do
        expect(
          types_merger
            .call(
              Dry::Logic::Operations::Or,
              {foo: Types::Integer, bar: Types::Integer},
              {foo: Types::String}
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
                    [:nominal, [Integer, {}, {}]],
                    [
                      :predicate,
                      [:type?, [[:type, Integer], [:input, Undefined]]]
                    ]
                  ]
                ],
                [
                  :constrained,
                  [
                    [:nominal, [String, {}, {}]],
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
                [:nominal, [Integer, {}, {}]],
                [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
              ]
            ]
          }
        )
      end
    end

    [
      [Dry::Logic::Operations::And, :and],
      [Dry::Logic::Operations::Implication, :implication]
    ].each do |op_class, op_node_type|
      context op_class do
        it "applies all when keys collide" do
          expect(
            types_merger
              .call(
                op_class,
                {foo: Types::Integer.constrained(gteq: 1)},
                {foo: Types::Integer.constrained(lteq: 3)}
              )
              .transform_values(&:to_ast)
          ).to eq(
            {
              foo: [
                :constrained,
                [
                  [:nominal, [Integer, {}, {}]],
                  [
                    op_node_type,
                    [
                      [
                        :and,
                        [
                          [
                            :predicate,
                            [:type?, [[:type, Integer], [:input, Undefined]]]
                          ],
                          [
                            :predicate,
                            [:gteq?, [[:num, 1], [:input, Undefined]]]
                          ]
                        ]
                      ],
                      [
                        :and,
                        [
                          [
                            :predicate,
                            [:type?, [[:type, Integer], [:input, Undefined]]]
                          ],
                          [
                            :predicate,
                            [:lteq?, [[:num, 3], [:input, Undefined]]]
                          ]
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
                op_class,
                {foo: Types::Hash.schema(bar: Types::Integer)},
                {foo: Types::Hash.schema(baz: Types::Integer)}
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
                                        [:nominal, [Integer, {}, {}]],
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
                                        [:nominal, [Integer, {}, {}]],
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
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ]
                    ]
                  ],
                  [
                    op_node_type,
                    [
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ],
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ]
                    ]
                  ]
                ]
              ]
            }
          )
        end

        it "merges schema types on collision with multiple constraints" do
          expect(
            types_merger
              .call(
                op_class,
                {foo: Types::Hash.schema(bar: Types::Integer.optional)},
                {
                  foo: Types::Hash.schema(baz: Types::Integer.optional).optional
                }
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
                                      :sum,
                                      [
                                        [
                                          :constrained,
                                          [
                                            [:nominal, [NilClass, {}, {}]],
                                            [
                                              :predicate,
                                              [
                                                :type?,
                                                [
                                                  [:type, NilClass],
                                                  [:input, Undefined]
                                                ]
                                              ]
                                            ]
                                          ]
                                        ],
                                        [
                                          :constrained,
                                          [
                                            [:nominal, [Integer, {}, {}]],
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
                                        ],
                                        {}
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
                                      :sum,
                                      [
                                        [
                                          :constrained,
                                          [
                                            [:nominal, [NilClass, {}, {}]],
                                            [
                                              :predicate,
                                              [
                                                :type?,
                                                [
                                                  [:type, NilClass],
                                                  [:input, Undefined]
                                                ]
                                              ]
                                            ]
                                          ]
                                        ],
                                        [
                                          :constrained,
                                          [
                                            [:nominal, [Integer, {}, {}]],
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
                                        ],
                                        {}
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
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ]
                    ]
                  ],
                  [
                    op_node_type,
                    [
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ],
                      [
                        :and,
                        [
                          [
                            :or,
                            [
                              [
                                :predicate,
                                [
                                  :type?,
                                  [[:type, NilClass], [:input, Undefined]]
                                ]
                              ],
                              [
                                :predicate,
                                [:type?, [[:type, Hash], [:input, Undefined]]]
                              ]
                            ]
                          ],
                          [
                            :predicate,
                            [:type?, [[:type, Hash], [:input, Undefined]]]
                          ]
                        ]
                      ]
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
              .call(op_class, {foo: Types::Any}, {foo: Types::Integer})
              .transform_values(&:to_ast)
          ).to eq(
            {
              foo: [
                :constrained,
                [
                  [:nominal, [Integer, {}, {}]],
                  [
                    :predicate,
                    [:type?, [[:type, Integer], [:input, Undefined]]]
                  ]
                ]
              ]
            }
          )
        end

        it "uses the rhs if the rhs is a subclass of lhs" do
          expect(
            types_merger
              .call(
                op_class,
                {foo: Types::Hash},
                {foo: Types::Hash.schema(bar: Types::Integer)}
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
                                [:nominal, [Integer, {}, {}]],
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
                    op_node_type,
                    [
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ],
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ]
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
              .call(op_class, {foo: Types::Integer}, {foo: Types::Any})
              .transform_values(&:to_ast)
          ).to eq(
            {
              foo: [
                :constrained,
                [
                  [:nominal, [Integer, {}, {}]],
                  [
                    :predicate,
                    [:type?, [[:type, Integer], [:input, Undefined]]]
                  ]
                ]
              ]
            }
          )
        end

        it "uses the lhs if the lhs is a subclass of rhs" do
          expect(
            types_merger
              .call(
                op_class,
                {foo: Types::Hash.schema(bar: Types::Integer)},
                {foo: Types::Hash}
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
                                [:nominal, [Integer, {}, {}]],
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
                    op_node_type,
                    [
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ],
                      [
                        :predicate,
                        [:type?, [[:type, Hash], [:input, Undefined]]]
                      ]
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
end
