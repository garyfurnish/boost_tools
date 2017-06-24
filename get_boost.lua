-- mkdir boost ; cd boost ; lua ../git-submodules-clone-HEAD.lua https://github.com/boostorg/boost.git .
local module_url = arg[1] or 'https://github.com/boostorg/boost.git'
local module = arg[2] or module_url:match('.+/([_%d%a]+)%.git')
local branch = arg[3] or 'master'
function execute(command)
print('# ' .. command)
return os.execute(command)
end
-- execute('rm -rf ' .. module)
if not execute('git clone --single-branch --branch master --depth=1 ' .. module_url .. ' ' .. module) then
io.stderr:write('can\'t clone repository from ' .. module_url .. ' to ' .. module .. '\n')
return 1
end
-- cd $module ; git submodule update --init --recursive --remote --no-fetch --depth=1
execute('mkdir -p ' .. module .. '/.git/modules')
assert(io.input(module .. '/.gitmodules'))
local lines = {}
for line in io.lines() do
table.insert(lines, line)
end
local submodule
local path
local submodule_url
for _, line in ipairs(lines) do
local submodule_ = line:match('^%[submodule %"([_%d%a]-)%"%]$')
if submodule_ then
submodule = submodule_
path = nil
submodule_url = nil
else
local path_ = line:match('^%s*path = (.+)$')
if path_ then
path = path_
else
submodule_url = line:match('^%s*url = (.+)$')
end
if submodule and path and submodule_url then
-- execute('rm -rf ' .. path)
local git_dir = module .. '/.git/modules/' .. path:match('^.-/(.+)$')
-- execute('rm -rf ' .. git_dir)
execute('mkdir -p $(dirname "' .. git_dir .. '")')
if not execute('git clone --depth=1 --single-branch --branch=' .. branch .. ' --separate-git-dir ' .. git_dir .. ' ' .. module_url .. '/' .. submodule_url .. ' ' .. module .. '/' .. path) then
io.stderr:write('can\'t clone submodule ' .. submodule)
return 1
end
path = nil
submodule_url = nil
end
end
end