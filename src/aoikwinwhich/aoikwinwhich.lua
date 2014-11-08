--

-- Copied from |http://lua-users.org/wiki/SplitJoin|.
-- Renamed from |explode| to |string.split|.
-- BEG
function string.split(p,d)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end
-- END

-- Copied from |http://lua-users.org/wiki/StringTrim|.
-- Renamed from |trim12| to |string.trim|.
-- BEG
function string.trim(s)
 local from = s:match"^%s*()"
 return from > #s and "" or s:match(".*%S", from)
end
-- END

-- Copied from |http://lua-users.org/wiki/StringRecipes|.
-- Renamed from |string.ends| to |string.endswith|.
-- BEG
function string.endswith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end
-- END

function map(item_s, func)
    local item_s_new = {}

    for key, val in ipairs(item_s) do
        item_s_new[key] = func(val)
    end

    return item_s_new
end

function filter(item_s, func)
    local item_s_new = {}

    local ord = 0

    for key, val in ipairs(item_s) do
        if func(val) then
            ord = ord + 1
            item_s_new[ord] = val
        end
    end

    return item_s_new
end

function any(item_s, func)
    for key, val in ipairs(item_s) do
        if func(val) then
            return true
        end
    end

    return false
end

function uniq(item_s)
    --
    local val_ord_s = {}

    local ord_val_s_uniq = {}

    --
    local ord = 1

    for _, val in ipairs(item_s) do
        --
        val_exists = val_ord_s[val]
        --- can be nil

        if (not val_exists) then
            val_ord_s[val] = ord

            ord_val_s_uniq[ord] = val

            ord = ord + 1
        end
    end

    table.sort(ord_val_s_uniq, function (va, vb) return val_ord_s[va] < val_ord_s[vb] end)

    return ord_val_s_uniq
end

-- Copied from |http://stackoverflow.com/a/4991602|.
-- Choose not to add dependency on |lfs|
--  (http://keplerproject.github.io/luafilesystem/) so use a simple func that
--  only checks if the file is openable, not sure if it is regular file.
-- BEG
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
-- END

function find_executable(prog)
    -- 8f1kRCu
    local env_var_PATHEXT = os.getenv('PATHEXT')
    --- can be null

    -- 6qhHTHF
    -- split into a list of extensions
    local sep = ';'

    local ext_s = (not env_var_PATHEXT) and {} or env_var_PATHEXT:split(sep)

    -- 2pGJrMW
    -- strip
    ext_s = map(ext_s, function(x) return x:trim() end)

    -- 2gqeHHl
    -- remove empty
    ext_s = filter(ext_s, function(x) return x ~= '' end)

    -- 2zdGM8W
    -- convert to lowercase
    ext_s = map(ext_s, function(x) return x:lower() end)

    -- 2fT8aRB
    -- uniquify
    ext_s = uniq(ext_s)

    -- 4ysaQVN
    env_var_PATH = os.getenv('PATH')
    --- can be nil

    -- 6mPI0lg
    local dir_path_s = (not env_var_PATH) and {} or env_var_PATH:split(sep)

    -- 5rT49zI
    -- insert empty dir path to the beginning
    --
    -- Empty dir handles the case that |prog| is a path, either relative or
    --  absolute. See code 7rO7NIN.
    table.insert(dir_path_s, 1, '')

    -- 2klTv20
    -- uniquify
    dir_path_s = uniq(dir_path_s)

    --
    local prog_has_ext = any(ext_s, function(x) return prog:lower():endswith(x) end)

    -- 6bFwhbv
    exe_path_s = {}

    for _, dir_path in ipairs(dir_path_s) do
        -- 7rO7NIN
        -- synthesize a path with the dir and prog
        path = (dir_path == '') and prog or dir_path .. '\\' .. prog

        -- 6kZa5cq
        -- assume the path has extension, check if it is an executable
        if prog_has_ext and file_exists(path) then
            exe_path_s[#exe_path_s+1] = path
        end

        -- 2sJhhEV
        -- assume the path has no extension
        for _, ext in ipairs(ext_s) do
            -- 6k9X6GP
            -- synthesize a new path with the path and the executable extension
            path_plus_ext = path .. ext

            -- 6kabzQg
            -- check if it is an executable
            if file_exists(path_plus_ext) then
                exe_path_s[#exe_path_s+1] = path_plus_ext
            end
        end
    end

    -- 8swW6Av
    -- uniquify
    exe_path_s = uniq(exe_path_s)

    --
    return exe_path_s
end

function main()
    -- 9mlJlKg
    if (#arg ~= 1) then
        -- 7rOUXFo
        -- print program usage
        print([[Usage: aoikwinwhich PROG]])
        print('')
        print([[#/ PROG can be either name or path]])
        print([[aoikwinwhich notepad.exe]])
        print([[aoikwinwhich C:\Windows\notepad.exe]])
        print('')
        print([[#/ PROG can be either absolute or relative]])
        print([[aoikwinwhich C:\Windows\notepad.exe]])
        print([[aoikwinwhich Windows\notepad.exe]])
        print('')
        print([[#/ PROG can be either with or without extension]])
        print([[aoikwinwhich notepad.exe]])
        print([[aoikwinwhich notepad]])
        print([[aoikwinwhich C:\Windows\notepad.exe]])
        print([[aoikwinwhich C:\Windows\notepad]])

        -- 3nqHnP7
        return
    end

    -- 9m5B08H
    -- get name or path of a program from cmd arg
    local prog = arg[1]

    -- 8ulvPXM
    -- find executables
    local path_s = find_executable(prog)

    -- 5fWrcaF
    -- has found none, exit
    if (#path_s == 0) then
        -- 3uswpx0
        return
    end

    -- 9xPCWuS
    -- has found some, output
    local txt = table.concat(path_s, '\n')

    print(txt)

    -- 4s1yY1b
    return
end

--/
main()
