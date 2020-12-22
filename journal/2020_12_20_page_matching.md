# 12/22/2020
An idea that may belong in a future project - hard to say quite yet.  It has to do with the ActionJob interface, and how to get 'batches' working.

The simplest way to really get batches rocking would probably be to just implement some locks within redis.  This, however, would create another dependence on Redis that I'd rather avoid.  As it stands, jobs can currently still work using AsyncJob, and the Rails cache has a dev version that also doesn't use Redis.

I'm wondering about doing some locking in the database.  The idea goes something like this:

## Loops and Locks
### Site Refresh Loop Job 
For a domain that is 'active', we queue a refresh job.  This job registers itself with Site model itself, along with a start time (and timeout?).  The job can refresh as many pages as it wants to (a single "batch" worth of jobs), and checks to see that it's still the active job for refresh for that Site between each download.  It then will un-register itself from running.  It queues up 'itself" to run again.

Every X time interval, the Site Scrape Manager job runs. It checks on pages that need to be refreshed, and on currently running jobs (by ID and time started).  If there is no active job, or if the last one is taking way too long, we replace it with a new one (which kills the old one).

This system works well for refreshing jobs, since this is something we should just do continuously for all domains that we want to keep up to date.  It also avoids having long running processes, which have their own disadvantages.  It might even make sense to have the Job only refresh a single page at a time before requeueing itself...(or is that too much Redis/db overhead...?)

### Site Parse Loop Job
Parsing depends on Refreshing.  We can only parse jobs that have already been refreshed.  So we have another loop here for Parsing, looking at jobs have been refreshed since the last parse.  Similarly, we keep our locks with the Site, but since we have no worry about rate limiting by Site parsing, we can have as many workers (running in loops) as we need.  1 is probably fine though.

### Site Index Loop Job
Indexing get's us into less tested territory.  The Index process may take a very long time per page, especially for "full parse".  Having a single page loop might make plenty of sense here, since we may not want to have more than one of these running at a time...?  Not really sure that's a concern here - long running processes are bad for their own reasons.

### Caching
Aaaand then caching.  Really not sure how to feel about this one.  This is the enormous job.  Not sure if this should be done incrementally or what.  Seems to be the sort of thing to do once a Site hits some threshold of successful Indexes, since future indexes may make past Caching obsolete.

Maybe for some constant successfully indexed number of pages, we do a cache operation.

## Singles vs Batches
I'm curious to examine the pros and cons of having batches of operations performed in a Job vs just a single operation.  I imagine there is a significant tradeoff of Redis overhead and instantiating all the job objects.  But is there also better visibility into the system?  Some useful logging we get for free?  Does it make things easier to reason about? Does it keep memory consumption low in some useful way?

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
