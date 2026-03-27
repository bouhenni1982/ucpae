local M = {}

function M.process_event(event, extensions)
  for _, extension in ipairs(extensions or {}) do
    local handled, command = extension(event)
    if handled then
      return command
    end
  end

  if event.role == "button" then
    return {
      action = "speak",
      text = string.format("%s button", event.name)
    }
  end

  if event.role == "checkbox" then
    return {
      action = "speak",
      text = string.format("%s checkbox", event.name)
    }
  end

  if event.type == "scroll" then
    return {
      action = "speak",
      text = "Scrolled"
    }
  end

  return {
    action = "speak",
    text = string.format("%s %s", event.name, event.role)
  }
end

return M
