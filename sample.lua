require 'torch'
require 'nn'

require 'LanguageModel'


local cmd = torch.CmdLine()
cmd:option('-checkpoint', 'cv/checkpoint_4000.t7')
cmd:option('-length', 2000)
cmd:option('-start_text', '')
cmd:option('-sample', 1)
cmd:option('-temperature', 1)
cmd:option('-gpu', 0)
cmd:option('-gpu_backend', 'cuda')
cmd:option('-verbose', 0)
cmd:option('-stream', 0)
cmd:option('-opencl', 0)
cmd:option('-n', 1)
local opt = cmd:parse(arg)


local checkpoint = torch.load(opt.checkpoint)
local model = checkpoint.model

local msg
if opt.gpu >= 0 and opt.gpu_backend == 'cuda' then
  require 'cutorch'
  require 'cunn'
  cutorch.setDevice(opt.gpu + 1)
  model:cuda()
  msg = string.format('Running with CUDA on GPU %d', opt.gpu)
elseif opt.gpu >= 0 and opt.gpu_backend == 'opencl' then
  require 'cltorch'
  require 'clnn'
  model:cl()
  msg = string.format('Running with OpenCL on GPU %d', opt.gpu)
else
  msg = 'Running in CPU mode'
end
if opt.verbose == 1 then print(msg) end

model:evaluate()

local i = 1
while i <= opt.n do
  if opt.n > 1 then
    print('\n\n/* === SAMPLE ' .. i .. ' === */')
  end
  local sample = model:sample(opt)
  -- If streaming then sample has already been printed
  if opt.stream == 0 and opt.opencl == 0 then
    print(sample)
  end
  i = i + 1
end
