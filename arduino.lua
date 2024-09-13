local M = {}

-- List of supported boards
M.boards = {
  { name = "Arduino Uno", fqbn = "arduino:avr:uno" },
  { name = "Arduino Nano", fqbn = "arduino:avr:nano" },
  { name = "Arduino Mega", fqbn = "arduino:avr:mega" },
  { name = "Arduino Yun", fqbn = "arduino:avr:yun" },  -- Support for Arduino Yun
  -- Add more boards if necessary
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
      -- Create a folder in ~/Arcom for this sketch and specific board
      local output_dir = os.getenv("HOME") .. "/Arcom/" .. sketch_name .. "/" .. choice.name
      os.execute("mkdir -p " .. output_dir)

      -- Correct command for compilation using system() function
      local compile_cmd = "arduino-cli compile --fqbn=" .. choice.fqbn .. " --output-dir=" .. output_dir .. " " .. vim.fn.expand("%:p")
      print("Running command: " .. compile_cmd)  -- Debugging print
      local result = vim.fn.system(compile_cmd)

      -- Print the result to check if any error occurred
      print(result)
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
      -- Upload for Arduino Yun using IP address
      if choice.fqbn == "arduino:avr:yun" then
        vim.ui.input({ prompt = "Enter IP Address (e.g., 192.168.x.x): " }, function(ip)
          if ip then
            local upload_cmd = "arduino-cli upload --fqbn=" .. choice.fqbn .. " --port=" .. ip .. " " .. vim.fn.expand("%:p")
            local result = vim.fn.system(upload_cmd)
            print(result)
          end
        end)
      else
        -- Upload for other boards via USB port
        vim.ui.input({ prompt = "Enter Port (e.g., /dev/ttyUSB0): " }, function(port)
          if port then
            local upload_cmd = "arduino-cli upload --fqbn=" .. choice.fqbn .. " --port=" .. port .. " " .. vim.fn.expand("%:p")
            local result = vim.fn.system(upload_cmd)
            print(result)
          end
        end)
      end
    end
  end)
end

return M
