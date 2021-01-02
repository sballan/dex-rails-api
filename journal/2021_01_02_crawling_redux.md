# 1/02/2021
PageRank is cool!  With this new central design feature, time to rethink lots of other stuff.  Let's pay some tech debt...

## Batches...
Perhaps I should've created the batches first...anyhow, the whole design changes with Batches.

## Crawling!
With an understanding of PageRank, it's more clear to me that there _is_ a good reason to crawl lots of pages, and not just the ones I want to be searchable.  That reason being - we need to evaluate the quality of the page!  We need PageRank.

So the services need to change a bit - I want a CrawlService.  The CrawlService is in charge of organizing downloading pages distributed across a crawl.

We need a new model - a RedisPage model, or CrawlService::Page model - something like that.  Crawl::Page.  This is a page before it is inserted into our db.  We keep track of urls that have been downloaded/parsed/etc, generally across a batch.

The idea is that we don't want to download the same pages over and over as we crawl, and we don't want to need to hit the db in order to have state about our pages.

We could - for instance, create all pages at the end of a crawl in a crawl batch callback.  This might overcomplicate things - we'll need to see.

In combination with the ability to lock a site before downloading a page, we can distribute crawling across our workers, only downloading pages that haven't already been downloaded, and with a crude ability to rate limit our sites (just lock the site for an extra second or two for each download...crude, but should work)

This should build a good graph to use in our matrix.  Get us good intel about how good our pages are.

## Page
Our page model needs a bit of work.  It's way too heavy - we need to have a simple construct that (together with links) can just represent the graph of the Web.

Here's a crazy idea - this could almost be it's _own_ database.  Just pages (urls) and links, no title, no link text, nothing.

Anyhow - a stripped down page model will also allow us to better perform batch updates.  We can use insert/upsert when we know _all_ the data for our page.  This means that while crawling we could insert many pages at once, automatically ignoring duplicates by url, and batch update our pages rank with upsert (without overwriting other fields, like timestamps).

So new page model - literally just `id`, `url`, `rank`.  That is _it_.

So where should the other data go?  Do we really need it?  Partly, the other data was being used because of our workarounds from not having Batches.  Page lifecycle will look different now.

So a PageMeta table, something like that?  Keeping all the various statuses.

### Page Lifecycle
So what is our new Page lifecycle?

1. We crawl a page.  We should keep track of crawls that have been initiated from a particular page.  In other words - we should have some idea of whether a page was downloaded at the start or end of a crawl, the depth matters.  We persist the page, and all of its links when we crawl.  Leaf nodes therefore are downloaded, but not crawled.
2. We fetch a page.  Fetching may involve getting from the Web, or may invovle using our own cached (and parsed?) version.
3. We index a page.  Not all pages are indexed, and the ones that are indexed are not all indexed in the same way.  We care about "distance to a crawled site". We keep track of _Sites_ that are being crawled, and while we will download (and maybe even crawl) pages that are not on the Site as part of that process, we don't index those sites in the same way.  At the furthest level, we have pages that are downloaded (with their links parsed), but are not indexed.
4. We calculate PageRank.  This is done on large groups of pages, but when pages fall through the cracks we can always rerun the algo from the starting place of a page that was missed (or has a low _iterations_ count).

### Page Meta
We'll need to rewrite the current status scopes to query the table for PageMeta, or whatever we call the other table. Too bad that this will make the Rails magic less magical.