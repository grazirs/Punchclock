# frozen_string_literal: true

class Ability
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize(user)
    if user.is_a?(AdminUser)
      admin_user_permitions(user)
    else
      user_permitions(user)
    end
  end

  private

  def admin_user_permitions(user)
    if user.is_super?
      can :manage, :all
    else
      can :manage, [
        AdminUser,
        User, Office,
        Project,
        Client,
        RegionalHoliday,
        Allocation,
        Evaluation,
        Questionnaire,
        Skill
      ], company_id: user.company_id

      can :read, Punch, company_id: user.company_id

      can :create, [
        AdminUser,
        User,
        Office,
        Project,
        Client,
        Allocation,
        Evaluation,
        Questionnaire,
        RegionalHoliday,
        Skill
      ]
      cannot :destroy, [User, Project]
    end
  end

  def user_permitions(user)
    can :manage, Punch, company_id: user.company_id, user_id: user.id
    can :read, User, company_id: user.company_id
    can :edit, User, id: user.id
    can :update, User, id: user.id

    if user.office_head?
      can :manage, Evaluation, company_id: user.company_id
      cannot [:destroy, :edit, :update], Evaluation
    end
  end
end
