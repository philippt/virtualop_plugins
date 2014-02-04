add_columns [ :name, :state, :owner ]

execute do |params|
  Machine.all.map { |x|
    {
      'name' => x.name,
      'state' => x.state,
      'owner' => x.owner
    }
  }
end
