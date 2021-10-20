module Stringventory

  # Enum defining the resource to perform an action on.
  enum StrVResource
    Guitar
    Strings
    Database
    None
  end

  # Enum defining the action to take on a particular resource.
  enum StrVAction
    Create
    Delete
    Update
    StringChange
    List
    None
  end
end
