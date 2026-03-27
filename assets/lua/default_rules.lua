local rules = {}

function rules.describe(event)
  if event.role == "button" then
    return event.name .. " button"
  end

  if event.role == "checkbox" then
    return event.name .. " checkbox"
  end

  if event.type == "scroll" then
    return "Scrolled"
  end

  return event.name .. " " .. event.role
end

return rules
