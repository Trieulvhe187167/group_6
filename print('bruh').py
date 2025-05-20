import urllib.request, urllib.parse, urllib.error
from bs4 import BeautifulSoup

url = input("Enter - ")
html = urllib.request.urlopen(url).read()

soup = BeautifulSoup(html, "html.parser")

# Tìm tất cả thẻ <span> có class="comments"
tags = soup.find_all('span', class_='comments')

total = 0
count = 0
for tag in tags:
    num = int(tag.text)
    total += num
    count += 1

print("Count", count)
print("Sum", total)
