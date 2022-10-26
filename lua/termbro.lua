----------------------
-- Composing Plugin --
----------------------

-- empty plugin
local termbro = {}

-- get modules
local term = require('term')
local node = require('node')
local django = require('django')
local rails = require('rails')

termbro.term = term
termbro.node = node
termbro.django = django
termbro.rails = rails

-- return complete plugin
return termbro
