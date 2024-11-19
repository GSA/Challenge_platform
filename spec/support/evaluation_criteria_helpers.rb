module EvaluationCriteriaHelpers
  def random_values_for_weighted_scoring(num_criteria)
    unless num_criteria > 0 && num_criteria < 100
      raise ArgumentError, "Number of generated values must be between 0 and 100"
    end

    values = Array.new(num_criteria) { rand(1..100) }
    total = values.sum.to_f
    normalized_values = values.map { |v| [(v / total * 100).to_i, 1].max }

    difference = 100 - normalized_values.sum
    normalized_values[0] += difference

    normalized_values
  end
end
