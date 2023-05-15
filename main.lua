local module = {
	greetings_s = {
		["hi"] = true;
		["hello"] = true;
		["ello"] = true;
		["ey"] = true;
		["yo"] = true;
		["wsg"] = true;
		["wsp"] = true;
		["whats up"] = true;
		["what's up"] = true;
		["how's it going"] = true;
		["wake up"] = true;
	};
	greetings_st = {
		["hi"] = "Hi,";
		["wake up"] = "Hm-?, I'm awake..";
		["hello"] = "Hello,";
		["ello"] = "Hello,";
		["ey"] = "Ey,";
		["yo"] = "Yo,";
		["wsg"] = "What's good,";
		["wsp"] = "What's up,";
		["whats up"] = "What's up,";
		["what's up"] = "What's up,";
		["what's good"] = "Hello,";
		["whats good"] = "Hello,";
		["how's it going"] = "How's it going,";		
	};
	addons = {
		"on",
		"a t",
		"that"
	};
	addons_ad = {
		"opinion",
		"good",
		"annoying"
	};
	addons_ad_r = {
		[1] = {
			SPEC = "opinion";
			CONTENT = "Hm, I don't exactly have a specific opinion on ";
		},
		[2] = {
			SPEC = "good";
			CONTENT = "No, I'd not say so that I'm good at ";
		},
		[3] = {
			SPEC = "annoying";
			CONTENT = "I don't think so that I'm annoying ";
		}
	};
	replacements = {
		[1] = {
			SPEC = "my";
			CONTENT = "your";
		}
	};
	requests = {
		"can",
	};
	requests_a = {
		"kill",
		"craft"
	};
	requests_r = {
		[1] = {
			SPEC = "kill";
			CONTENT = "Alright, I'll kill ";
			ACTION = function(Target)
				pcall(function()
					Target.Character.Humanoid.Health = 0
				end)
			end,
		},
		[2] = {
			SPEC = "craft";
			CONTENT = "Yes, I can craft ";
			ACTION = function(Target)
				pcall(function()
					
				end)
			end,
		}
	}
}
local function toTable(s)
	local t = {}
	s:gsub(".", function(c) table.insert(t, c) return c end)
	return t
end
local function findtarget(s)
	for i,v in ipairs(game.Players:GetPlayers()) do
		if string.lower(v.Name) == string.lower(s) then
			return v
		end
	end
	return nil
end

module.GetIfDistance = function(Player)
	local Character = Player.Character
	if Character then
		if Character.PrimaryPart then
			local a = (script.Parent.Parent.HumanoidRootPart.Position - Character.PrimaryPart.Position).Magnitude
			if a <= 10 then
				return true
			else
				return false
			end
		end
	end
end;

module.Talk = function(Message,Player)
	game.Chat:Chat(script.Parent.Parent.Head,Message,Enum.ChatColor.White);
end;

module.RemoveSigns = function(Message)
	local signs = {
		"?",
		".",
		",",
		"!",
		"-",
		"¸",
		"'",
		'"'
	}
	local Q = toTable(Message)
	for i,v in ipairs(Q) do
		for x,y in ipairs(signs) do
			if v == y then
				table.remove(Q,i)
			end
		end
	end
	local formed = "";
	for i,v in ipairs(Q) do
		formed = formed..v;
	end
	return formed
end

module.GetResponse = function(Message,Player)
	local greeting_r = module.greetings_s[string.lower(Message)]
	local k = false
	local isrequest = false
	local requesttype = "";
	for i in module.requests do
		if string.find(string.lower(Message),string.lower(module.requests[i])) then
			if k == false then
				k = true
				isrequest = true
				requesttype = string.gsub(module.requests[i],string.sub(module.requests[i],1,1),string.upper(string.sub(module.requests[i],1,1)))
			end
		end
	end
	if greeting_r then
		local msg = module.greetings_st[string.lower(Message)].." how may I help you, "..Player.Name.."?"
		module.Talk(msg,Player);
	elseif not greeting_r and not isrequest then
		local Addon
		local Addon_ad
		local split = string.split(Message," ")
		for i,v in ipairs(module.addons) do
			if string.find(string.lower(Message),v) then
				Addon = v
			end
		end
		for i,v in ipairs(module.addons_ad) do
			if string.find(string.lower(Message),v) then
				Addon_ad = v
			end
		end
		local index_addon
		local l = false;
		for i in split do
			if split[i] == Addon and l == false then
				l = true
				index_addon = i
			end
		end
		
		local msg = "";
		local object = "";
		local f = false
		local diff
		if l == true then
			local curi
			for i in split do
				curi = i
				if i > index_addon and f == false then
					f = true
					object = split[i]
					if #split > i then
						for x,y in ipairs(module.replacements) do
							if split[i] == y.SPEC then
								object = y.CONTENT .. " " .. split[i+1]
							else
								object = split[i] .. " " .. split[i+1]
							end
						end
					end
				end
			end
			diff = #split - curi
		end
		
		for i,v in ipairs(module.addons_ad_r) do
			if v.SPEC == Addon_ad then
				msg = v.CONTENT .. object .. "."
			end
		end
		module.Talk(msg,Player)
	elseif isrequest then
		local msg = "";
		local split = string.split(Message," ")
		table.remove(split,1)
		table.remove(split,1)
		local removed
		if not split[2] then
			removed = module.RemoveSigns(split[1])
		else
			removed = module.RemoveSigns(split[2])
		end
		local target = findtarget(removed)
		local i___ = 0
		if target then
			for m,a in ipairs(module.requests_r) do
				if a.SPEC == split[1] then
					msg = a.CONTENT .. target.Name.."."
					i___ = m
				end
			end
			if msg == "" then
				msg = "Hmm, you didn't specify what you would like me to do with that individual."
			end
		end
		pcall(function()
			coroutine.resume(coroutine.create(function()
				module.Talk(msg,Player)
				task.wait(0.5)
				module.requests_r[i___].ACTION(target);
			end))
		end)
	end
end

return module
