# frozen_string_literal: true

class Visitor < AppUser
  def become_lead!
    becomes!(Lead)
    self.type = 'Lead'
    save
  end
end
