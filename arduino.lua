local M = {}

-- List of supported boards
M.boards = {
  { name = "Arduino Uno", fqbn = "arduino:avr:uno" },
  { name = "Arduino Nano", fqbn = "arduino:avr:nano" },
  { name = "Arduino Mega", fqbn = "arduino:avr:mega" },
  { name = "Arduino Yun", fqbn = "arduino:avr:yun" },  -- Support for Arduino Yun
}

-- Function to compile Arduino sketch
function M.compile()
  vim.ui.select(M.boards, {
    prompt = "Select Arduino Board for Compilation:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      -- Get the name of the sketch file
      local sketch_name = vim.fn.expand("%:t:r")
      -- Create a folder in ~/Arcom for this sketch
      local output_dir = vim.fn.expand("~/Arcom/" .. sketch_name .. "/" .. choice.name)
      os.execute("mkdir -p '" .. output_dir .. "'")
      
      -- Get the full path of the current sketch
      local sketch_path = vim.fn.expand("%:p")
      
      -- Ensure the sketch path and output path are wrapped in quotes
      local cmd = "arduino-cli compile --fqbn " .. choice.fqbn .. " --build-path '" .. output_dir .. "' '" .. sketch_path .. "'"
      vim.cmd("!" .. cmd)
    end
  end)
end

-- Function to upload Arduino sketch
function M.upload()
  vim.ui.select(M.boards, {
    prompt = "Select Arduino Board for Upload:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      -- Get the full path of the current sketch
      local sketch_path = vim.fn.expand("%:p")

      -- Upload for Arduino Yun using IP address
      if choice.fqbn == "arduino:avr:yun" then
        vim.ui.input({ prompt = "Enter IP Address (e.g., 192.168.x.x): " }, function(ip)
          if ip then
            local cmd = "arduino-cli upload --fqbn " .. choice.fqbn .. " --port " .. ip .. " '" .. sketch_path .. "'"
            vim.cmd("!" .. cmd)
          end
        end)
      else
        -- Upload for other boards via USB port
        vim.ui.input({ prompt = "Enter Port (e.g., /dev/ttyUSB0): " }, function(port)
          if port then
            local cmd = "arduino-cli upload --fqbn " .. choice.fqbn .. " --port " .. port .. " '" .. sketch_path .. "'"
            vim.cmd("!" .. cmd)
          end
        end)
      end
    end
  end)
end

return M
