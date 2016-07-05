class Contractor < User

  default_scope {joins(:roles).where(roles: {name: 'contractor'})}

end