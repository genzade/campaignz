NEGATED_MATCHER_DEFINITIONS = [
  %i[not_change change]
].freeze

NEGATED_MATCHER_DEFINITIONS.each do |negated_macher_definition|
  RSpec::Matchers.define_negated_matcher(*negated_macher_definition)
end
