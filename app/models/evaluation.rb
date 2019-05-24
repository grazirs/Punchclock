# frozen_string_literal: true

class Evaluation < ApplicationRecord
  SCORE_RANGE = (1..10).to_a.freeze

  after_create :update_office_score

  belongs_to :evaluated, class_name: 'User'
  belongs_to :evaluator, class_name: 'User'
  belongs_to :questionnaire
  belongs_to :company
  has_many   :answers, dependent: :destroy
  belongs_to :company

  accepts_nested_attributes_for :answers

  delegate :english?, to: :questionnaire


  validates :evaluated, :evaluator, :questionnaire, :score, presence: true
  validates :score, inclusion: { in: SCORE_RANGE }
  validates :english_level, presence: true, if: :english?

  scope :by_kind, -> (kind) { joins(:questionnaire).merge(Questionnaire.public_send(kind)) }

  enum english_level: [
    :beginner, :intermediate, :advanced, :fluent
  ]

  private

  def update_office_score
    evaluated.office.calculate_score
  end
end
