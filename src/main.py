import os
import sys
import datetime
import requests
import PyRSS2Gen
from datetime import timedelta, datetime as dt
from dotenv import load_dotenv
from requests.auth import HTTPBasicAuth

load_dotenv()


def generate_rss(notifications):
    items = []
    for notification in notifications:
        title = "[" + notification["repository"]["name"] + "] " + \
            notification["subject"]["title"]
        description = "[" + notification["reason"] + "] " + \
            notification["subject"]["type"]
        items.append(PyRSS2Gen.RSSItem(
            title=title,
            link=notification["subject"]["url"],
            description=description,
            guid=PyRSS2Gen.Guid(notification["url"]),
            pubDate=dt.strptime(notification["updated_at"], "%Y-%m-%dT%H:%M:%S%z")))
    rss = PyRSS2Gen.RSS2(
        title="GitHub Notifications Feed",
        link="https://github.com/notifications",
        description="The latest notifications from your GitHub account.",
        lastBuildDate=datetime.datetime.now(),
        items=items)
    rss.write_xml(open("./output/feed.xml", "w"))


def get_notifications(username, token):
    date = dt.today() - datetime.timedelta(days=14)
    since_last_week = date.isoformat(timespec='seconds')
    headers = {'Accept': 'application/vnd.github.v3+json'}
    payload = {'all': 'true', 'since': since_last_week}
    return requests.get('https://api.github.com/notifications',
                        auth=HTTPBasicAuth(username, token),
                        headers=headers,
                        params=payload)


def main():
    try:
        os.remove("./output/feed.xml")
    except OSError:
        pass
    try:
        GITHUB_USERNAME = os.getenv("GITHUB_USERNAME")
        GITHUB_ACCESS_TOKEN = os.getenv("GITHUB_ACCESS_TOKEN")
        response = get_notifications(GITHUB_USERNAME, GITHUB_ACCESS_TOKEN)
        response.raise_for_status()
        generate_rss(response.json())
        print("RSS feed generated successfully!")
    except requests.exceptions.RequestException as e:
        print(e)
        sys.exit(1)


if __name__ == "__main__":
    main()
