----------------------
-- Composing Plugin --
----------------------

-- empty plugin
local termbro = {}

-- get modules
local django = require('django')
local node = require('node')
local python = require('python')
local rails = require('rails')
local term = require('term')

termbro.django = django
termbro.node = node
termbro.python = python
termbro.rails = rails
termbro.term = term

-- return complete plugin
return termbro
