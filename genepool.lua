GenePool = {
	control = {
		Update = function(self, events)
			if events["space"] and events["space"].event == "pressed" then
				console:Log("===== New generation ["..#GenePool.gens.."] =====")
				GenePool.Run(GenePool.gens, 8)
			end
		end
	}
}

function GenePool.Init()
	GenePool.gens = {
		Genome.Create("Superstition"),
		Genome.Create("Antidisestablishmentarionism")
	}
end

function GenePool.Run(genomes, max)
	local count = #genomes
	for i=1, count do
		local o = genomes[love.math.random(count)]
		if o~=genomes[i] then
			local a,b = GenePool.Breed(genomes[i], o)
			table.insert(genomes, a)
			table.insert(genomes, b)
		end
	end
	while #genomes > max do 
		table.remove(genomes, love.math.random(#genomes))
	end
	
	console:Log("pool size: "..#genomes)
end

function GenePool.Breed(genomeA, genomeB)
	local a = genomeA:Copy()
	local b = genomeB:Copy()
	a:Cross(b)
	a:Mutate()
	b:Mutate()
	return a,b
end