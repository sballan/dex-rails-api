Site.create(home_url: "https://harrypotter.fandom.com/wiki/Main_Page", host: "harrypotter.fandom.com", scrape_active: true)
Page.create(url: "https://harrypotter.fandom.com/wiki/Main_Page", meta_attributes: {fetch_status: :ready})


Site.create(home_url: "http://tolkiengateway.net/wiki/Tolkien_fandom", host: "tolkiengateway.net", scrape_active: true)
Page.create(url: "http://tolkiengateway.net/wiki/Tolkien_fandom", meta_attributes: {fetch_status: :ready})
Site.create(home_url: "https://oldschool.runescape.wiki", host: "oldschool.runescape.wiki", scrape_active: true)
Page.create(url: "https://oldschool.runescape.wiki", meta_attributes: {fetch_status: :ready})

Site.create(home_url: "https://en.wikipedia.org/wiki/Main_Page", host: "en.wikipedia.org", scrape_active: true)
Page.create(url: "https://en.wikipedia.org/wiki/Main_Page", meta_attributes: {fetch_status: :ready})


