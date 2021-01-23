# DEX: The World's Worst Search Engine®
www.theworldsworstsearchengine.com

## How?
Using Ruby, a beautiful language that should never be used in systems that need to be fast and efficient.  Also uses Rails, which similarly should never be used for anything like this.  A standard web-app architecture is used: Postgres database, Redis cache, S3 object storage, React front end.

Shoestring budget as a design choice:  the whole thing can run on Heroku free dynos, using a persistence layer that costs about $15/month.

## Why?
Because building a competitive search engine is impossible anyhow.  By building this in Ruby and Rails, the engine can both be understood by a student learning about web search, and be interesting enough to actually get worked on as a side project.

## What does it (will it) do?
It'll be able to search some very small corner of the web, either configured by me or by a user.  Search results will be fast, accurate, and might even be (a little) useful.

More importantly, the project explores the requirements of web search, and the real world difficulties of building such a system.


