# 12/20/2020
Here starts the journal. Bit of an unusual idea, keeping a journal in your souce code, but it's my project so I'm gonna do it how I like.
 
## A New System
At this point, there's bit a fair bit of work on the old system - mostly R&D oriented.  It's time to start building the features I want.
 
### Domain Oriented Scraping
Domains can be configured to scrape every so often.  We determine at scrape time which pages should be refreshed, parsed, indexed, and cached. 
### Page Matching, different index levels
We do different levels of indexing.  It's way to gnarly to index everything for every page, and we don't get much benefit from it.

#### Level 0
The lowest level of indexing, will only find very particular words, and only if the page is already somewhat popular.  We just the individual words in the title.

#### Level 1
In addition to the level 0 indexing, we do a full parse of the title.  This means we look at sequences of words up to whatever our maximum number is (maybe up to 3 to start with? Or maybe it needs to be the length of the sequence?), and with a distance at maximum (maybe the length of the sequence?)

This means we can reliably get hits when someone searches for the text in the title.

#### Level 2
Adds a "level 0" level of indexing for heading elements on the page.

#### Level 3
Adds a "level 1" level of indexing for heading elements on the page.

Levels 4 and 5 are the same for the page content as a whole, or whatever else there is.  The pattern continues.


#### The higher the index level, the higher priority the results.
When page_matches are saved, the length and distance of the match are saved.  A longer length means more words were directly matched - meaning a better hit.  A bigger distance means more words were missing in the source, meaning our match is more approximate.

At low indexing priority, we only spend the time it would take to get individual words that exactly match.  These would be Length 1, Distance 0.  This is the cheapest indexing we can do.

At high indexing priority, we take the time to get non-exact matches, and to better match long strings of words.  This takes much more time.  The order should go something like this:

1. Top level domain Page that is actively being scraped
2. Top level domain page that is not actively being scraped
3. Page linked to from domain page being scraped
4. Page in a domain that is being actively scraped
5. Page linked to from a domain page that is not being scraped.
6. Page distant from domain that has page_rank of at least X
7. Page with low page rank.