return function(event)
  if event.name == "Special Action" then
    return true, {
      action = "speak",
      text = "Special Action from user extension"
    }
  end

  return false, nil
end
