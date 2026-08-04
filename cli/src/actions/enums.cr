module Stringventory

  # Enum defining the resource to perform an action on.
  enum Resource
    Guitar
    Strings
    StringChange
    Database
    None
  end

  # Enum defining the action to take on a particular resource.
  enum Action
    Create
    Delete
    Update
    List
    None
  end
end
