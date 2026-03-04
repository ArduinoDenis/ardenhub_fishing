
	-- ═══════════════════════════════════════
	-- ARDENHUB FISHING - ITEMS
	-- Aggiungi questi item in ox_inventory/data/items.lua
	-- ═══════════════════════════════════════

	-- ─────────────────────────────────────
	-- ATTREZZATURA
	-- ─────────────────────────────────────
	['fishingrod'] = {
	    label = 'Canna da Pesca',
	    weight = 2000,       
	    stack = false,       
	    close = true,
	},

	['fishbait'] = {
	    label = 'Esca',
	    weight = 50,         
	    stack = true,
	    close = true,
	},

	-- ─────────────────────────────────────
	-- PESCI - COMUNE
	-- ─────────────────────────────────────
	['anchovy'] = {
	    label = 'Acciuga',
	    weight = 200,        
	    stack = true,
	    close = true,
	    server = {
	        export = 'ardenhub_fishing.anchovy' 
	    }
	},

	-- ─────────────────────────────────────
	-- PESCI - NON COMUNE
	-- ─────────────────────────────────────
	['trout'] = {
	    label = 'Trota',
	    weight = 500,        
	    stack = true,
	    close = true,
	},

	['salmon'] = {
	    label = 'Salmone',
	    weight = 800,        
	    stack = true,
	    close = true,
	},

	-- ─────────────────────────────────────
	-- PESCI - RARO
	-- ─────────────────────────────────────
	['tuna'] = {
	    label = 'Tonno',
	    weight = 3000,      
	    stack = true,
	    close = true,
	},

	-- ─────────────────────────────────────
	-- PESCI - LEGGENDARIO
	-- ─────────────────────────────────────
	['swordfish'] = {
	    label = 'Pesce Spada',
	    weight = 8000,       
	    stack = true,
	    close = true,
	},