# blaguesland-crawler

## Overview

This scripts crawls the defined URLs on [blaguesland](http://blaguesland.free.fr) to extract jokes and post them to the specified SosMessage API URL.

Sample usage:

    ./blaguesland-crawler.rb -u http://localhost:3000 -c 4f6a4f80744e34609b3c8127

Full options:

    Usage: blaguesland-crawler.rb [options]
    -c, --category-id CATEGORY_ID    The category id where to post the jokes
    -u, --sosmessage-url URL         The SosMessage API url
    -m, --max-characters MAX         MAX characters of the joke
    -n, --dry-run                    Don't actually post the jokes, only display them
    -h, --help                       Display this screen
