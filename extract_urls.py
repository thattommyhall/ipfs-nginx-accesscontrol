import re
import csv

get_url = re.compile(r"/ipfs/[^\s\?]+")
with open("access.log.1") as f:
    with open("urls.txt", "w") as csvfile:
        fieldnames = ["method", "url", "body", "headers"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for line in f:
            match = get_url.search(line)
            if match:
                url = f"http://localhost:3000{match[0]}"
                writer.writerow({"method": "GET", "url": url, "body": ""})
